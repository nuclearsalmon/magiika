require "../base.cr"


module Magiika::Node
  class UnaryExpr < Node
    def initialize(
        position : Lang::Position,
        @oper : String,
        @obj : Node)
      super(position)
    end

    def eval(scope : Magiika::Scope::Scope) : Magiika::Node::Node
      obj = @obj.eval(scope)
      obj[0][@oper].call([] of Node, scope)
    end
  end
end
