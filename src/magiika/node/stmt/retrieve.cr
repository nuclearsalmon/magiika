module Magiika::Node
  class Retrieve < Node
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken)
      super(position)
    end

    def eval(scope : Magiika::Scope::Scope) : Node
      return scope.get(@ident)
    end
  end
end