require 'active_support/concern'

module Oriented
  module Vertex
    extend ActiveSupport::Concern

    included do
      include Oriented::Vertex::Delegates
      include Oriented::Wrapper
      include Oriented::VertexMethods
      include Oriented::Persistence
      include Oriented::VertexPersistence
      include Oriented::ClassName
      include Oriented::Relationships
      include Oriented::Properties
    end

    def wrapper
      self
    end
  end
end

