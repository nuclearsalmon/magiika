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
          return left_oper.as(Object::Function).call_safe_raise(
            [
              Object::Argument.new(left, SELF_NAME),
              Object::Argument.new(right, nil)
            ],
            scope)
        else
          raise Error::Internal.new("binary operation where operation is not a function")
        end
      end
    end
  end
end
