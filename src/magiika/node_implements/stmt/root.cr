module Magiika
  class Node::Root < NodeClass
    def initialize(
        @statements : Array(Psuedo::Node),
        position : Position? = nil)
      position = Position.new(0, 0, position.try(&.filename))
      super(position)
    end

    def eval(scope : Scope) : Node::Nil
      @statements.each { |stmt| stmt.eval(scope) }
      return Node::Nil.instance
    end
  end
end
