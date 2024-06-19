module Magiika
  class Node::Stmts < NodeClass
    def initialize(
        @statements : Array(Psuedo::Node),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::Node
      result : Psuedo::Node = Node::Nil.instance
      @statements.each { |stmt| result = stmt.eval(scope) }
      result
    end
  end
end
