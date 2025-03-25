module Magiika
  class Ast::UnaryExpression < AstBase
    def initialize(
        position : Position,
        @oper : ::String,
        @obj : Ast,
        @r_side : ::Bool)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      obj = @obj.eval(scope)
      extended_oper = @r_side ? @oper : ("_" + @oper)

      if (!(obj.responds_to?(:scope)) || \
          (obj_oper = obj.scope.retrieve?(extended_oper)).nil?)
        raise Error::UndefinedMethod.new(extended_oper, obj, position?)
      else
        obj_oper = obj_oper.eval(scope)

        if obj_oper.is_a?(Object::Function)
          return obj_oper.as(Object::Function).call_safe_raise(
            [Object::Argument.new(obj, SELF_NAME)], scope)
        else
          return obj_oper
        end
      end
    end
  end
end
