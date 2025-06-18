module Magiika
  class Ast::IfElse < AstBase
    def initialize(
        position : Position?,
        @condition : Ast,
        @on_true : Ast? = nil,
        @on_false : Ast? = nil)
      super(position)
    end

    def eval(scope : Scope) : Object
      target = @condition.eval_bool(scope) ? @on_true : @on_false
      target.nil? ? scope.definition(Object::Nil) : target.eval(scope)
    end
  end
end
