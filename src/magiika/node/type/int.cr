module Magiika
  class Node::Int < NodeClassBase
    include Node::Psuedo::Number

    getter value : InternalNumberType

    def initialize(
        @value : InternalIntegerType,
        position : Lang::Position? = nil)
      super(position)
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


    # ⭐ Members
    # ---

    # define members code
    Magiika.def_members_feat

    private def self._add(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Node::Psuedo::Number).value.to_i32

        return Node::Int.new(self_value + other_value).as(NodeObj)
      {% end %}
    end

    private def self._sub(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Node::Psuedo::Number).value.to_i32

        return Node::Int.new(self_value - other_value).as(NodeObj)
      {% end %}
    end

    Magiika.def_fn "+",
      [FnParam.new("other", NumberUnion)],
      _add,
      Node::Int

    Magiika.def_fn "-",
      [FnParam.new("other", NumberUnion)],
      _sub,
      Node::Int
  end
end
