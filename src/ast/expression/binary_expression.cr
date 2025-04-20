module Magiika
  class Ast::BinaryExpression < AstBase
    def initialize(
        position : Position,
        @left : Ast,
        @oper : ::String,
        @right : Ast)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      left = @left.eval(scope)
      right = @right.eval(scope)

      if (!(left.responds_to?(:scope)) || \
          (left_oper = left.scope.retrieve?(@oper)).nil?)
        raise Error::UndefinedMethod.new(@oper, left, position?)
      else
        left_oper = left_oper.eval(scope)

        if left_oper.is_a?(Object::Function)
          args = [] of Object::Argument

          # Note: Avoid doing this on Magiika::Object.class. It's fine on Magiika::Object.
          unless left.is_a?(Magiika::Object.class)
            args << Object::Argument.new(left, SELF_NAME)
            args << Object::Argument.new(left.class, THIS_NAME)
          else
            args << Object::Argument.new(left, THIS_NAME)
          end

          args << Object::Argument.new(right, nil)

          return left_oper.as(Object::Function).call_safe_raise(args, scope)
        else
          raise Error::Internal.new("binary operation where operation is not a function")
        end
      end
    end
  end
end
