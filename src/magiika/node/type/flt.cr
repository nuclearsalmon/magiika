module Magiika::Node
  class Flt < Node
    def initialize(@value : ::Float32, position)
      super(position)
    end

    def to_s
      return @value.to_s
    end

    def eval(scope : Magiika::Scope::Scope) : Node:Flt
      return self
    end
  end
end
