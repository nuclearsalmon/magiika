module Magiika
  class Ast::BinaryExpression < AstBase
    def initialize(
        position : Position,
        @left : Ast,
        @oper : ::String,
        @right : Ast)
      super(position)
    end

    def eval(scope : Scope) : Object
      left = @left.eval(scope)
      right = @right.eval(scope)

      if (left_oper = left.scope.retrieve?(@oper).try(&.value)).nil?
        raise Error::UndefinedMethod.new(@oper, left, position?)
      else
        if left_oper.is_a?(Object::FunctionInstance)
          args = [] of Object::Argument

          Util.obj_to_args!(left, args, scope)
          args << Object::Argument.new(right, scope)

          left_oper.as(Object::FunctionInstance).call_safe_raise(args, scope)
        else
          raise Error::Internal.new("binary operation where operation is not a function")
        end
      end
    end
  end
end
