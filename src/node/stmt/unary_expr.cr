module Magiika
  class Node::UnaryExpr < Node
    def initialize(
        position : Position,
        @oper : String,
        @obj : Node,
        @r_side : ::Bool)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      obj = @obj.eval(scope)
      extended_oper = @r_side ? @oper : ("_" + @oper)

      unless obj.is_a?(TypeNode)
        raise Error::Internal.new("Expected a TypeNode from eval")
      end

      obj_oper = obj[extended_oper]?

      if obj_oper.nil?
        raise Error::UndefinedMethod.new(extended_oper, obj)
      else
        obj_oper = obj_oper.eval(scope)

        if obj_oper.is_a?(Node::Fn)
          return obj_oper.as(Node::Fn).call_safe_raise(
            [FnArg.new(obj, "self")], scope)
        else
          return obj_oper
        end
      end
    end
  end
end
