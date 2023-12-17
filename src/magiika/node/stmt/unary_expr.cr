require "../base.cr"


module Magiika
  class Node::UnaryExpr < NodeClassBase
    def initialize(
        position : Lang::Position,
        @oper : String,
        @obj : Node,
        @r_side : ::Bool)
      super(position)
    end

    def eval(scope : Scope) : Node
      obj = @obj.eval(scope)
      node = obj[@oper]?
      
      if node.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        if node.node_is_a_inh?(Function)
          return node.as(Function).call_safe_raise(FnArgs.new, scope)
        else
          return node
        end
      end
    end
  end
end
