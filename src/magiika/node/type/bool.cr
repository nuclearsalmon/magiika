module Magiika::Node
  class Bool < Node
    def initialize(@value : ::Bool, position)
      super(position)
    end

    def to_s
      return @value.to_s
    end

    def eval(scope : Magiika::Scope::Scope) : Node:Bool
      return self
    end
  end
end
