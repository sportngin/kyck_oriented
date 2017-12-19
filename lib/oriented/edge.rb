module Oriented
  module Edge
    extend ActiveSupport::Concern

    included do
      include Oriented::Edge::Delegates
      include Oriented::Wrapper
      include Oriented::EdgeMethods
      include Oriented::Persistence
      include Oriented::EdgePersistence
      include Oriented::Properties
      include Oriented::ClassName
    end

    def wrapper
      self
    end
  end
end
