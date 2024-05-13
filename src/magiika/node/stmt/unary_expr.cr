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
      extended_oper = @r_side ? @oper : ("_" + @oper)
      obj_oper = obj[extended_oper]?

      if obj_oper.nil?
        raise Error::UndefinedMethod.new(extended_oper)
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
