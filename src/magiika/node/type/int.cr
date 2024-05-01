module Magiika
  class Node::Int < NodeClassBase
    protected getter value

    @members = Hash(String, Node::Function).new

    def add(other : Node::Int) : Node::Int
      return Int.new(@value + other.value)
    end

    def initialize(@value : ::Int32, position : Lang::Position? = nil)
      super(position)
      @members["+"] = NativeFn.new(
        "+",
        [FnParam.new("obj", Node::Int)],
        ->(scope : Scope){
          meta = scope.get("obj")
          node = meta.data

          if node.is_a?(Node::Int) || node.is_a?(Node::Flt)
            Node::Int.new(@value + node.value.to_i).as(NodeObj)
          else
            raise Error::Internal.new("wrong type: #{node.class} in #{self}.");
          end
        },
        FnRet.new(Node::Int),
      )
    end

    def []?(ident) : NodeObj?
      return @members[ident]?
    end

    def to_s_internal : String
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
