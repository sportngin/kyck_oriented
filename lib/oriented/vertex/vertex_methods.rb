module Oriented
  module VertexMethods
    extend ActiveSupport::Concern

    module ClassMethods

      class << self
        include Oriented::Core::TransactionWrapper
      end

      #TODO: Query methods
      def find(rid)
        vertex = Oriented.graph.get_vertex(rid)
        return nil unless vertex
        vertex.wrapper
      end
      wrap_in_transaction :find

      def find_all
        Oriented.graph.get_vertices_of_class(Oriented::Registry.odb_class_for(self.name.to_s), false).map(&:wrapper)
      end
      wrap_in_transaction :find_all

      def load_entity(rid)
          vertex = Oriented::Core::JavaVertex._load(rid)
          return nil if vertex.nil?
          return vertex if vertex.class == Oriented::Core::JavaVertex
          vertex.kind_of?(self) ? vertex : nil
      end

      def to_adapter
        self
      end


      protected

      def field_names
        @field_names ||= []
      end
    end
  end
end
