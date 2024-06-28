module Magiika
  class Node::Stmts < Node
    def initialize(
        @statements : Array(Node),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Node
      result : Node = Node::Nil.instance
      @statements.each { |stmt| result = stmt.eval(scope) }
      result
    end
  end
end
