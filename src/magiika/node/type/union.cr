module Magiika
  class Node::Union < NodeClassBase
    property types : Array(Node.class)

    def initialize(@types : Array(Node.class))
      super(Lang::Position.new)
    end

    def eval(scope : Scope) : Node
      self
    end

    def validate(node : Node) : ::Bool
      return true if node.is_a?(Node::Union)
      return @types.includes?(node.class)
    end
  end
end
