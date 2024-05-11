module Magiika
  class Node::BinaryExpr < NodeClassBase
    def initialize(
        position : Lang::Position,
        @left : NodeObj,
        @oper : String,
        @right : NodeObj)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      left = @left.eval(scope)
      right = @right.eval(scope)
      left_oper = left[@oper]?

      if left_oper.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        left_oper = left_oper.eval(scope)

        if left_oper.type?(Node::Fn)
          return left_oper.as(Node::Fn).call_safe_raise(
            [FnArg.new("self", left), FnArg.new(nil, right)], scope)
        else
          raise Error::Internal.new("binary operation where operation is not a function")
        end
      end
    end
  end
end
