module Magiika
  class Node::BinaryExpr < NodeClass
    def initialize(
        position : Position,
        @left : Psuedo::Node,
        @oper : String,
        @right : Psuedo::Node)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::TypeNode
      left = @left.eval(scope)
      right = @right.eval(scope)

      unless left.is_a?(Psuedo::TypeNode)
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
