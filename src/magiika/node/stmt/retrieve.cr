module Magiika
  class Node::RetrieveVar < NodeClassBase
    def initialize(
        position : Lang::Position?,
        @ident : Lang::MatchedToken)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      scope.get(@ident).eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      scope.get(@ident).eval_bool(scope)
    end
  end

  class Node::RetrieveMember < NodeClassBase
    def initialize(
        position : Lang::Position?,
        @source : NodeObj,
        @action : NodeObj)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      return @source.eval(scope)
    end

    def eval_bool(scope : Scope) : ::Bool
      return @source.eval_bool(scope)
    end
  end
end