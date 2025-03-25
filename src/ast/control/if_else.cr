module Magiika
  class Ast::IfElse < AstBase
    def initialize(
        position : Position?,
        @condition : Ast,
        @on_true : Ast? = nil,
        @on_false : Ast? = nil)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      target = @condition.eval_bool(scope) ? @on_true : @on_false
      target.nil? ? Object::Nil.instance : target.eval(scope)
    end
  end
end
