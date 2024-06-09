module Magiika
  class Node::RetrieveVar < NodeClass
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

  class Node::RetrieveMember < NodeClass
    def initialize(
        @source : Psuedo::Node,
        @action : Psuedo::Node,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::Node
      return @source.eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      return @source.eval_bool(scope)
    end
  end
end