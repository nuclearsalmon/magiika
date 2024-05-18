module Magiika
  class Node::Root < NodeClassBase
    def initialize(
        @statements : Array(NodeObj),
        position : Lang::Position? = nil)
      position = Lang::Position.new(0, 0, position.try(&.filename))
      super(position)
    end

    def eval(scope : Scope) : Node::Nil
      @statements.each { |stmt| stmt.eval(scope) }
      return Node::Nil.instance
    end
  end
end
