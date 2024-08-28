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

      if (!(obj.responds_to?(:scope)) || \
          (obj_oper = obj.scope.retrieve?(extended_oper)).nil?)
        raise Error::UndefinedMethod.new(extended_oper, obj, position?)
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
