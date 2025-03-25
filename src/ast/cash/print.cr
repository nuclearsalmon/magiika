module Magiika
  class Ast::CashPrint < AstBase
    def initialize(
        position : Position?,
        @stmt : Ast)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      print "✨ " + @stmt.eval(scope).to_s_internal + "\n"
      Object::Nil.instance
    end
  end
end
