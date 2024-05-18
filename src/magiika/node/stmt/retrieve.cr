module Magiika
  class Node::RetrieveVar < NodeClassBase
    def initialize(
        @ident : String,
        position : Lang::Position? = nil)
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
        @source : NodeObj,
        @action : NodeObj,
        position : Lang::Position? = nil)
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