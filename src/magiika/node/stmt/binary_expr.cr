module Magiika
  class Node::BinaryExpr < NodeClassBase
    def initialize(
        position : Lang::Position,
        @left : NodeD,
        @oper : String,
        @right : NodeD)
      super(position)
    end

    def eval(scope : Scope) : NodeD
      left = @left.eval(scope)
      right = @right.eval(scope)
      node = left[@oper]?

      if node.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        node = node.eval(scope)

        if node.node_is_a_inh?(Function)
          return node.as(Function).call_safe_raise(
            [FnArg.new(nil, right)], scope)
        else
          return node
        end
      end
    end
  end
end
