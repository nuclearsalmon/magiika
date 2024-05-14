module Magiika
  enum AssignMode
    Declare  # declare a new value (no pre-existing value)
    Replace  # replace an existing value
    Any      # any of the modes, doesn't care
  end

  class Node::AssignVar < NodeClassBase
    def initialize(
        position : Lang::Position,
        @ident : Lang::MatchedToken,
        @value : NodeObj,
        @mode : AssignMode = AssignMode::Any,
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      value = @value.eval(scope)

      if @mode == AssignMode::Declare && scope.exist?(@ident)
        raise Error::Internal.new("Variable already exists: \'#{@ident}\'")
      end
      if @mode == AssignMode::Replace && !scope.exist?(@ident)
        raise Error::Internal.new("Variable does not exist: \'#{@ident}\'")
      end

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
