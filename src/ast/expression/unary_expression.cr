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
      extended_oper = @r_side ? @oper : ("_#{@oper}")

      if (obj_oper = obj.scope.retrieve?(extended_oper).try(&.value)).nil?
        raise Error::UndefinedMethod.new(extended_oper, obj, position?)
      else
        if obj_oper.is_a?(Object::Function)
          args = [] of Object::Argument

          Util.obj_to_args!(obj, args)

          return obj_oper.as(Object::Function).call_safe_raise(args, scope)
        else
          return obj_oper
        end
      end
    end
  end
end
