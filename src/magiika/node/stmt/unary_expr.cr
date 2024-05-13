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
      obj_oper = obj[@oper]?

      if obj_oper.nil?
        raise Error::Internal.new("unknown method `:#{@oper}'.")
      else
        obj_oper = obj_oper.eval(scope)

        if obj_oper.type?(Node::Fn)
          return obj_oper.as(Node::Fn).call_safe_raise(
            [FnArg.new("self", obj)], scope)
        else
          return obj_oper
        end
      end
    end
  end
end
