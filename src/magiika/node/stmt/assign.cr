module Magiika::Node
  class Assign < Node
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken, 
        @value : Node, 
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Magiika::Scope::Scope) : Node
      case @oper
      when "="
        scope.set(@ident, @value)
      else
        raise Error::Internal.new("Unknown assignment operator: \'#{@oper}\'")
      end
      return @value
    end
  end
end
