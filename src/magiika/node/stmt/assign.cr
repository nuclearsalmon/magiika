module Magiika
  class Node::AssignVar < NodeClassBase
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken,
        @value : Node,
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Scope) : Node
      value = @value.eval(scope)
      case @oper
      when "="
        scope.set(@ident, value)
      else
        raise Error::Internal.new("Unknown assignment operator: \'#{@oper}\'")
      end

      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return False
    end
  end

  class Node::AssignMember < NodeClassBase
    def initialize(
        position : Lang::Position,
        @dest : Node,
        @value : Node,
        @oper : String)
      super(position)
    end

    def eval(scope : Scope) : Node
      value = @value.eval(scope)
      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return False
    end
  end
end
