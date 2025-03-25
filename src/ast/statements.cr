module Magiika
  class Ast::Statements < AstBase
    def initialize(
        @statements : Array(Ast),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      result : AnyObject = Object::Nil.instance
      @statements.each { |stmt| result = stmt.eval(scope) }
      result
    end
  end
end
