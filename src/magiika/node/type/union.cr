module Magiika
  class Node::Union < NodeClassBase
    property types : Array(NodeType)

    def initialize(@types : Array(NodeType))
      super
    end

    def eval(scope : Scope) : NodeObj
      self
    end

    def validate(node : NodeObj) : ::Bool
      return true if node.is_a?(Node::Union)
      return @types.includes?(node.class)
    end
  end
end
