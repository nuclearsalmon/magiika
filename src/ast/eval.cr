module Magiika
  class Ast::Eval < AstBase
    @block : ::Proc(Scope, Magiika::Object)

    def initialize(
        position : Position,
        &@block : ::Proc(Scope, Magiika::Object))
      super(position)
    end

    def eval(scope : Scope) : Magiika::Object
      @block.call(scope)
    end
  end
end
