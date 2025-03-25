module Magiika
  class Ast::CashPrint::Stringify < AstBase
    def initialize(
        position : Position?,
        @stmt : Ast)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      resolved_str = @stmt.eval(scope).to_s_internal
      print "✨ " + resolved_str + "\n"
      Object::String.new(resolved_str)
    end
  end
end
