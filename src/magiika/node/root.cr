module Magiika
  class Node::Root < NodeClassBase
    def initialize(
        @statements : Array(NodeObj),
        position : Lang::Position? = nil)
      position = Lang::Position.new(0, 0, position.try(&.filename))
      super(position)
    end

    def to_s : String
      ""
    end

    def to_s_internal : String
      ""
    end

    def eval(scope : Scope) : Node::NoPrint
      @statements.each { |stmt| stmt.eval(scope) }
      return Node::NoPrint.instance
    end
  end
end
