module Magiika
  class Ast::CashPrint::Stringify < AstBase
    def initialize(
        position : Position?,
        @stmt : Ast)
      super(position)
    end

    def eval(scope : Scope) : Object
      resolved_str = @stmt.eval(scope).to_s_internal
      print "✨ " + resolved_str + "\n"
      
      scope.definition(Magiika::Type::Str) \
        .create_instance(resolved_str)
    end
  end
end
