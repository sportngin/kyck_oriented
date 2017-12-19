require 'oriented'
class Model
  include Oriented::Vertex

  property :name

  has_n(:stylists)
  has_one(:drug_dealer).from(:clients)
  has_n(:requests).from(:target)
end

class DrugDealer
  include Oriented::Vertex
  property :name
  property :product
  has_n(:clients)
end

class Stylist
  include Oriented::Vertex
  property :name

  has_n(:pieces_of_gossip)
  has_one(:drug_dealer).from(:clients)
  has_n(:requests).from(:guru)
end

class ModelingRequest
  include Oriented::Vertex

  has_one(:target)
  has_one(:issuer)
  has_one(:guru)
end

class Agency
  include Oriented::Vertex

  has_n(:requests).from(:issuer)
  has_n(:models)
end

module AllPropertyTypes
  def define_properties(*types)
    property :default

    if types.empty? || types.include?(:fixnum)
      property :fixnum,      type: Fixnum
      property :fixnum_dflt, type: Fixnum, default: 42
    end
    if types.empty? || types.include?(:symbol)
      property :symbol,      type: :symbol
      property :symbol_dflt, type: :symbol, default: :active
    end
    if types.empty? || types.include?(:date)
      property :date,        type: Date
      property :date_dflt,   type: Date, default: Date.today
    end
    if types.empty? || types.include?(:time)
      property :time,        type: Time
      property :time_dflt,   type: Time, default: Time.now.utc
    end
    if types.empty? || types.include?(:bool)
      property :bool,        type: :boolean
      property :bool_dflt,   type: :boolean, default: true
    end
    if types.empty? || types.include?(:float)
      property :float,       type: Float
      property :float_dflt,  type: Float, default: 3.14
    end
    if types.empty? || types.include?(:set)
      property :set,         type: Set
      property :set_dflt,    type: Set, default: [1, 2, 3].to_set
    end
    if types.empty? || types.include?(:hash)
      property :hash,        type: Hash
      property :hash_dflt,   type: Hash, default: {a: 1}
    end
    if types.empty? || types.include?(:array)
      property :array
      property :array_dflt,  default: []
    end
  end
end

class VertexPropertyConverters
  include Oriented::Vertex
  extend AllPropertyTypes
end

def define_vertex_property_converter(type)
  name = "#{type.to_s.capitalize}VertexPropertyConverter"
  return Object.const_get(name.to_sym) if Object.const_defined?(name.to_sym)
  klass = Class.new(VertexPropertyConverters) { define_properties(type) }
  define_vertex_type name
  Object.const_set(name.to_sym, klass)
  klass
end

class AllVertexProperties < VertexPropertyConverters
  define_properties
end

class EdgePropertyConverters
  include Oriented::Edge
  extend AllPropertyTypes
end

def define_edge_property_converter(type)
  name = "#{type.to_s.capitalize}EdgePropertyConverter"
  return Object.const_get(name.to_sym) if Object.const_defined?(name.to_sym)
  klass = Class.new(EdgePropertyConverters) do
    class << self; attr_accessor :vertex_type; end
    self.vertex_type = define_vertex_property_converter(type)
    define_properties(type)
  end
  define_edge_type name
  Object.const_set(name.to_sym, klass)
  klass
end

class AllEdgeProperties < EdgePropertyConverters
  define_properties
end
