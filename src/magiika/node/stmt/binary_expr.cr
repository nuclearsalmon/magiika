require "../base.cr"


module Magiika::Node
  class BinaryExpr < Node
    def initialize(
        position : Lang::Position,
        @left : Node, 
        @oper : String,
        @right : Node)
      super(position)
    end

    def eval(scope : Magiika::Scope::Scope) : Magiika::Node::Node
      left = @left.eval(scope)
      right = @right.eval(scope)
      left[2][@oper].call([right], scope)
    end
  end
end
