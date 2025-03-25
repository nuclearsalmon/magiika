# AI Comment:
# Magiika::Ast represents the parsed syntax tree nodes of the language.
# These nodes are the intermediate representation between source code
# and executable objects. They are used during the parsing and 
# compilation phases but do not persist during runtime.

module Magiika
  module Ast
    include Positionable

    def eval(scope : Scope) : AnyObject
      Object::Nil.instance
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
