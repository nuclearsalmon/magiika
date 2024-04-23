module Magiika
  class Node::RetrieveVar < NodeClassBase
    def initialize(
        position : Lang::Position?,
        @ident : Lang::MatchedToken)
      super(position)
    end

    def eval(scope : Scope) : NodeD
      scope.get(@ident).eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      scope.get(@ident).eval_bool(scope)
    end
  end

  class Node::RetrieveMember < NodeClassBase
    def initialize(
        position : Lang::Position?,
        @source : Node,
        @action : Node)
      super(position)
    end

    def eval(scope : Scope) : NodeD
      return @source.eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      return @source.eval_bool(scope)
    end
  end
end