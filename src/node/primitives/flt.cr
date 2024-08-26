module Magiika
  class Node::Flt < TypeNode
    extend MembersFeat
    include Psuedo::Number

    getter value : InternalNumberType

    def initialize(
        @value : InternalFloatType,
        position : Position? = nil)
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


    # ⭐ Members
    # ---

    private def self.__neg(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32

        return Node::Flt.new(-self_value).as(TypeNode)
      {% end %}
    end

    private def self.__pos(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self

      {% begin %}
        return self_node
      {% end %}
    end

    private def self._add(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Psuedo::Number).value.to_f32

        result = self_value + other_value
        return Node::Flt.new(result.to_f32).as(TypeNode)
      {% end %}
    end

    private def self._sub(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Psuedo::Number).value.to_f32

        result = self_value - other_value
        return Node::Flt.new(result.to_f32).as(TypeNode)
      {% end %}
    end

    private def self._mul(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Psuedo::Number).value.to_f32

        result = self_value * other_value
        return Node::Flt.new(result.to_f32).as(TypeNode)
      {% end %}
    end

    private def self._div(scope : Scope::Fn) : TypeNode
      MembersFeat.get_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Psuedo::Number).value.to_f32

        result = self_value / other_value
        return Node::Flt.new(result.to_f32).as(TypeNode)
      {% end %}
    end

    MembersFeat.def_fn "_+",
      __pos,
      nil,
      Node::Flt

    MembersFeat.def_fn "_-",
      __neg,
      nil,
      Node::Flt

    MembersFeat.def_fn "+",
      _add,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    MembersFeat.def_fn "-",
      _sub,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    MembersFeat.def_fn "*",
      _mul,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    MembersFeat.def_fn "/",
      _div,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt
  end
end
