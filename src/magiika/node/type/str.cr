module Magiika
  class Node::Str < NodeClassBase
    def initialize(@value : ::String, position : Lang::Position? = nil)
      super(position)
    end

    def to_s_internal : String
      return @value.to_s
    end

    def eval(scope : Scope) : Node::Str
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != ""
    end
  end
end
