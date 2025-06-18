module Magiika
  class Ast::CashPrint < AstBase
    def initialize(
        position : Position?,
        @stmt : Ast)
      super(position)
    end

    def eval(scope : Scope) : Object
      print "✨ " + @stmt.eval(scope).to_s_internal + "\n"
      scope.definition(Object::Nil)
    end
  end
end
