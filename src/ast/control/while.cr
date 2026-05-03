module Magiika
  class Ast::While < AstBase
    def initialize(
        position : Position?,
        @condition : Ast,
        @body : Ast)
      super(position)
    end

    def eval(scope : Scope) : Object
      nil_t = scope.definition(Object::Nil)
      result : Object = nil_t

      while @condition.eval_bool(scope)
        scope.root_scope.check_resource_limits!
        begin
          result = @body.eval(scope)
        rescue signal : BreakSignal
          result = signal.value || nil_t
          break
        rescue NextSignal
          next
        end
      end

      result
    end
  end
end
