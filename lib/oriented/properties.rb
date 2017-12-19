require 'active_model'

module Oriented
  module Properties
    extend ActiveSupport::Concern

    RESTRICTED_PROPERTIES = %w[_orient_id]

    class RestrictedPropertyError < StandardError; end

    included do |base|
      include ActiveModel::Dirty

      base.extend ClassMethods

      # Alias the previous aref/aset methods to *_db
      alias_method :read_attribute_from_db, :[]
      alias_method :write_attribute_to_db, :[]=

      # Alias aref/aset to our own read/write attribute methods
      alias_method :[], :read_attribute
      alias_method :[]=, :write_attribute
    end

    def initialize_attributes(attributes)
      @_properties = {}
      self.attributes = attributes if attributes
    end

    # Mass-assign attributes.  Stops any protected attributes from being assigned.
    def attributes=(attributes, guard_protected_attributes = true)
      # attributes = sanitize_for_mass_assignment(attributes) if guard_protected_attributes

      multi_parameter_attributes = []
      attributes.each do |k, v|
        # if k.to_s.include?("(")
        #   multi_parameter_attributes << [k, v]
        # else
        respond_to?("#{k}=") ? send("#{k}=", v) : self[k] = v
        # end
      end
    end

    # @private
    def reset_attributes
      @_properties = {}
    end

    def props
      {}.tap do |props|
        property_names.each do |property_name|
          prval = self.respond_to?(property_name) ? send(property_name) : send(:[], property_name)
          props[property_name] = prval
        end
      end
    end

    def dbprops
      {}.tap do |dbprops|
        props.map do |key, value|
          dbprops[key] = converter(key).to_java(value)
        end
      end
    end

    def property_names
      @_properties ||= {}
      keys = @_properties.keys + self.class._props.keys.map(&:to_s)
      keys += __java_obj.property_keys.to_a if __java_obj
      keys.flatten.uniq
    end

    def write_attribute_with_conversion(key, value)
      dbval = converter(key).to_java(value)
      write_attribute_to_db(key, dbval)
    end

    def write_attribute(key, value)
      @_properties ||= {}
      key_s = key.to_s
      if !@_properties.has_key?(key_s) || @_properties[key_s] != value
        attribute_will_change!(key_s)
        @_properties[key_s] = value.nil? ? attribute_defaults[key_s] : value
      end
      value
    end

    def read_attribute_with_conversion(key)
      dbval = read_attribute_from_db(key)
      converter(key).to_ruby(dbval)
    end

    # Returns the locally stored value for the key or retrieves the value from
    # the DB if we don't have one
    def read_attribute(key)
      @_properties ||= {}
      key = key.to_s
      if @_properties.has_key?(key)
        @_properties[key]
      else
        @_properties[key] = if !new_record? && __java_obj.has_property?(key)
                              read_attribute_with_conversion(key)
                            else
                              attribute_defaults[key]
                            end
      end
    end

    module ClassMethods
      def attribute_defaults
        @attribute_defaults ||= {}
      end

      def _props
        @_props ||= {}
      end

      def property(*props)
        options = props.last.kind_of?(Hash) ? props.pop : {}
        props.each do |prop|
          prop = prop.to_s
          raise RestrctedPropertyError if RESTRICTED_PROPERTIES.include?(prop)
          next if _props.has_key?(prop)
          _props[prop] ||= {}
          options.each {|k, v| _props[prop][k] = v}

          attribute_defaults[prop] = options[:default]  if options.has_key?(:default)

          _props[prop][:converter] ||= Oriented::TypeConverters.converter(_props[prop][:type])

          create_property_methods(prop)
        end

      end

      def create_property_methods(name)
        define_method "#{name}" do
          send(:[], name)
        end

        define_method "#{name}=" do |val|
          send(:[]=, name, val)
        end

      end

      def _converter(pname)
        prop = _props[pname.to_s]
        (prop && prop[:converter]) || Oriented::TypeConverters::DefaultConverter
      end
    end

    # Write attributes to the Orient DB only if they're altered
    def write_changed_attributes
      @_properties.each do |attribute, value|
        write_attribute_with_conversion(attribute, value)  if changed_attributes.has_key?(attribute)
      end
    end

    def write_all_attributes
      mergeprops = attribute_defaults.merge(changed_attributes)
      mergeprops.each do |attribute, value|
        write_attribute_with_conversion(attribute, value)
      end
    end

    def write_default_values
      self.class.attribute_defaults.each_pair do |attr, val|
        self.send("#{attr}=", val)  unless changed_attributes.has_key?(attribute) || __java_obj.has_property?(attribute)
      end
    end

    def clear_changes
      @previously_changed = changes
      @changed_attributes.clear
    end

    def attribute_defaults
      self.class.attribute_defaults
    end

    def converter(name)
      self.class._converter(name)
    end
  end
end
