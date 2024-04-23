module Magiika
  class Node::Bool < NodeClassBase
    def initialize(@value : ::Bool, position : Lang::Position)
      super(position)
    end

    def to_s_internal : String
      return @value.to_s
    end

    def eval(scope : Scope) : self
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value
    end
  end
end
