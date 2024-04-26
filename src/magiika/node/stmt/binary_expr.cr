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
      node = left[@oper]?

      if node.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        node = node.eval(scope)

        if node.type?(Node::Function)
          return node.as(Node::Function).call_safe_raise(
            [FnArg.new(nil, right)], scope)
        else
          return node
        end
      end
    end
  end
end
