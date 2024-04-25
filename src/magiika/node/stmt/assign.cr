module Magiika
  class Node::DeclareVar < NodeClassBase
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken,
        @value : NodeObj,
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      value = @value.eval(scope)
      case @oper
      when "="
        if scope.exist?(@ident)
          raise Error::Internal.new("Variable exists already: \'#{@ident}\'")
        end
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

  class Node::AssignVar < NodeClassBase
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken,
        @value : NodeObj,
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      value = @value.eval(scope)
      case @oper
      when "="
        if !scope.exist?(@ident)
          raise Error::Internal.new("Variable does not exist: \'#{@ident}\'")
        end
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
        @dest : NodeObj,
        @value : NodeObj,
        @oper : String)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      value = @value.eval(scope)
      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return False
    end
  end
end
