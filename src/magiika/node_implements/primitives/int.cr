module Magiika
  class Node::Int < TypeNodeClass::ClassTyping
    include Psuedo::Resolved
    include Psuedo::Number

    getter value : InternalNumberType

    def initialize(
        @value : InternalIntegerType,
        position : Position? = nil)
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
    Members.def_members_feat

    private def self._add(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Psuedo::Number).value.to_i32

        result = self_value + other_value
        return Node::Int.new(result.to_i32).as(Psuedo::TypeNode)
      {% end %}
    end

    private def self._sub(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Psuedo::Number).value.to_i32

        result = self_value - other_value
        return Node::Int.new(result.to_i32).as(Psuedo::TypeNode)
      {% end %}
    end

    private def self._mul(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Psuedo::Number).value.to_i32

        result = self_value * other_value
        return Node::Int.new(result.to_i32).as(Psuedo::TypeNode)
      {% end %}
    end

    private def self._div(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Int).value.to_i32
        other_value = other_node.as(Psuedo::Number).value.to_i32

        result = self_value / other_value
        return Node::Int.new(result.to_i32).as(Psuedo::TypeNode)
      {% end %}
    end

    private def self.__cash(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self

      {% begin %}
        puts Node::Str.new(self_node.to_s_internal).to_s_internal
      {% end %}
      return Node::Nil.instance.as(Psuedo::TypeNode)
    end

    Members.def_fn "_$",
      __cash,
      nil,
      Node::Nil

    Members.def_fn "+",
      _add,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Int

    Members.def_fn "-",
      _sub,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Int

    Members.def_fn "*",
      _mul,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Int

    Members.def_fn "/",
      _div,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Int
  end
end
