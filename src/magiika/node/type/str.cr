module Magiika
  class Node::Str < NodeClassBase
    def initialize(@value : ::String, position : Lang::Position)
      super(position)
    end

    def initialize(@value : ::String)
      super(Lang::Position.new)
    end

    def to_s
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
