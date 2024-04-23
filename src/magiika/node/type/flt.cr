module Magiika
  class Node::Flt < NodeClassBase
    protected getter value

    def initialize(@value : ::Float32, position : Lang::Position)
      super(position)
    end

    def to_s_internal : String
      return @value.to_s
    end

    def eval(scope : Scope) : Node::Flt
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != 0.0
    end
  end
end
