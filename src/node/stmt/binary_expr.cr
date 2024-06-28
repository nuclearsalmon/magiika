module Magiika
  class Node::BinaryExpr < Node
    def initialize(
        position : Position,
        @left : Node,
        @oper : String,
        @right : Node)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      left = @left.eval(scope)
      right = @right.eval(scope)

      unless left.is_a?(TypeNode)
        raise Error::Internal.new("Expected a TypeNode from eval")
      end

      left_oper = left[@oper]?

      if left_oper.nil?
        raise Error::UndefinedMethod.new(@oper, left, @position)
      else
        left_oper = left_oper.eval(scope)

        if left_oper.is_a?(Node::Fn)
          return left_oper.as(Node::Fn).call_safe_raise(
            [
              FnArg.new(left, "self"),
              Node::FnArg.new(right, nil)
            ],
            scope)
        else
          raise Error::Internal.new("binary operation where operation is not a function")
        end
      end
    end
  end
end
