module Magiika
  # A control verb. Used for return, break, etc
  abstract class Ast::Control < AstBase
    getter value : Ast?

    def initialize(
        position : Position?,
        @value : Ast?)
      super(position)
    end

    def eval(scope : Scope) : Object
      nil_t = scope.definition(Object::Nil)
      (value = @value).nil? ? nil_t : value.eval(scope)
    end
  end

  class Ast::Return < AstBase::Control; end
  class Ast::Break < AstBase::Control; end
  class Ast::Next < AstBase::Control; end
end
