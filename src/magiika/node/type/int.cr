module Magiika
  class Node::Int < NodeClassBase
    protected getter value

    @members = Hash(String, Node::Function).new

    def add(other : Node::Int) : Node::Int
      return Int.new(@value + other.value, Lang::Position.new)
    end

    def initialize(@value : ::Int32, position : Lang::Position)
      super(position)
      @members["+"] = NativeFn.new(
        "+",
        [FnParam.new("obj", Constraint.new(Node::Int))],
        [Constraint.new(Node::Int)],
        ->(scope : Scope){
          meta = scope.get("obj")
          node = meta.data


          if node.is_a?(Node::Int) || node.is_a?(Flt)
            Node::Int.new(@value + node.value.to_i, Lang::Position.new).as(Node)
          else
            raise Error::Internal.new("wrong type: #{node.class} in #{self}.");
          end
        }
      )
    end

    def []?(ident) : Node?
      return @members[ident]?
    end

    def to_s
      return @value.to_s
    end

    def eval(scope : Scope) : Node::Int
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != 0
    end
  end
end
