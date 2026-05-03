module Magiika
  module Ast
    include Positionable

    def eval(scope : Scope) : Object
      scope.definition(Object::Nil)
    end

    # Feel free to override for fasttrack evaluation of bool.
    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end

  abstract class AstBase
    include Ast

    def initialize(@position : Position? = nil)
    end
  end
end
