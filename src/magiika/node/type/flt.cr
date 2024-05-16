module Magiika
  class Node::Flt < NodeClassBase
    include Node::Psuedo::Number

    getter value : InternalNumberType

    def initialize(
        @value : InternalFloatType,
        position : Lang::Position? = nil)
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

    # define members code
    Magiika.def_members_feat

    private def self._add(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Node::Psuedo::Number).value.to_f32

        result = self_value + other_value
        return Node::Flt.new(result.to_f32).as(NodeObj)
      {% end %}
    end

    private def self._sub(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Node::Psuedo::Number).value.to_f32

        result = self_value - other_value
        return Node::Flt.new(result.to_f32).as(NodeObj)
      {% end %}
    end

    private def self._mul(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Node::Psuedo::Number).value.to_f32

        result = self_value * other_value
        return Node::Flt.new(result.to_f32).as(NodeObj)
      {% end %}
    end

    private def self._div(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self, other

      {% begin %}
        self_value = self_node.as(Node::Flt).value.to_f32
        other_value = other_node.as(Node::Psuedo::Number).value.to_f32

        result = self_value / other_value
        return Node::Flt.new(result.to_f32).as(NodeObj)
      {% end %}
    end

    private def self.__cash(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self

      {% begin %}
        puts Node::Str.new(self_node.to_s_internal).to_s_internal
      {% end %}
      return Node::Nil.instance.as(NodeObj)
    end

    Magiika.def_fn "_$",
      __cash,
      nil,
      Node::Nil

    Magiika.def_fn "+",
      _add,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    Magiika.def_fn "-",
      _sub,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    Magiika.def_fn "*",
      _mul,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt

    Magiika.def_fn "/",
      _div,
      [FnParam.new("other", NUMBER_UNION)],
      Node::Flt
  end
end
