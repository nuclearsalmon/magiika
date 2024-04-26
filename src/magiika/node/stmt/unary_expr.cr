module Magiika
  class Node::UnaryExpr < NodeClassBase
    def initialize(
        position : Lang::Position,
        @oper : String,
        @obj : NodeObj,
        @r_side : ::Bool)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      obj = @obj.eval(scope)
      node = obj[@oper]?

      if node.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        if node.type?(Node::Function)
          return node.as(Node::Function).call_safe_raise(FnArgs.new, scope)
        else
          return node
        end
      end
    end
  end
end
