module Magiika::Node
  class Int < Node
    def initialize(@value : ::Int32, position)
      super(position)
    end

    def to_s
      return @value.to_s
    end

    def eval(scope : Magiika::Scope::Scope) : Node:Int
      return self
    end
  end
end
