class Magiika::Object::Flt < Magiika::PrimitiveObject
  extend MembersFeat
  include Magiika::Psuedo::Number

  getter value : InternalNumberType

  def initialize(
    @value : InternalFloatType,
    position : Position? = nil,
  )
    super(position)
  end

  def to_s_internal : ::String
    return @value.to_s
  end

  def eval_bool(scope : Scope) : ::Bool
    return @value != 0.0
  end

  # ⭐ Members
  # ---

  private def self.__neg(scope : Scope) : Object
    MembersFeat.get_scoped_vars self

    {% begin %}
      self_value = self_obj.as(Object::Flt).value.to_f32

      return Object::Flt.new(-self_value).as(Object)
    {% end %}
  end

  private def self.__pos(scope : Scope) : AnyObject
    MembersFeat.get_scoped_vars self

    {% begin %}
      return self_obj
    {% end %}
  end

  private def self._add(scope : Scope) : Object
    MembersFeat.get_scoped_vars self, other

    {% begin %}
      self_value = self_obj.as(Object::Flt).value.to_f32
      other_value = other_obj.as(Psuedo::Number).value.to_f32

      result = self_value + other_value
      return Object::Flt.new(result.to_f32).as(Object)
    {% end %}
  end

  private def self._sub(scope : Scope) : Object
    MembersFeat.get_scoped_vars self, other

    {% begin %}
      self_value = self_obj.as(Object::Flt).value.to_f32
      other_value = other_obj.as(Psuedo::Number).value.to_f32

      result = self_value - other_value
      return Object::Flt.new(result.to_f32).as(Object)
    {% end %}
  end

  private def self._mul(scope : Scope) : Object
    MembersFeat.get_scoped_vars self, other

    {% begin %}
      self_value = self_obj.as(Object::Flt).value.to_f32
      other_value = other_obj.as(Psuedo::Number).value.to_f32

      result = self_value * other_value
      return Object::Flt.new(result.to_f32).as(Object)
    {% end %}
  end

  private def self._div(scope : Scope) : Object
    MembersFeat.get_scoped_vars self, other

    {% begin %}
      self_value = self_obj.as(Object::Flt).value.to_f32
      other_value = other_obj.as(Psuedo::Number).value.to_f32

      result = self_value / other_value
      return Object::Flt.new(result.to_f32).as(Object)
    {% end %}
  end

  MembersFeat.def_fn "_+",
    __pos,
    nil,
    Object::Flt

  MembersFeat.def_fn "_-",
    __neg,
    nil,
    Object::Flt

  MembersFeat.def_fn "+",
    _add,
    [Object::Parameter.new("other", NUMBER_UNION)],
    Object::Flt

  MembersFeat.def_fn "-",
    _sub,
    [Object::Parameter.new("other", NUMBER_UNION)],
    Object::Flt

  MembersFeat.def_fn "*",
    _mul,
    [Object::Parameter.new("other", NUMBER_UNION)],
    Object::Flt

  MembersFeat.def_fn "/",
    _div,
    [Object::Parameter.new("other", NUMBER_UNION)],
    Object::Flt
end
