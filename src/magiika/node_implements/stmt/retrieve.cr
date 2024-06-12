module Magiika
  class Node::Retrieve < NodeClass
    getter ident : String

    def initialize(
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::TypeNode
      scope.get(@ident).eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      scope.get(@ident).eval_bool(scope)
    end
  end
end
