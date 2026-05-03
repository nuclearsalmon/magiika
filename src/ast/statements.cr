module Magiika
  class Ast::Statements < AstBase
    def initialize(
        @statements : Array(Ast),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Object
      result : Object = scope.definition(Object::Nil)
      @statements.each { |stmt|
        scope.root_scope.check_resource_limits!
        result = stmt.eval(scope)
      }
      result
    end
  end
end
