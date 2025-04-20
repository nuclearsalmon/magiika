class Magiika::Object::Flt < Magiika::PrimitiveObject
  include Magiika::Psuedo::Number

  def_static_scope()
  def_scope()
  getter value : InternalFloatType

  def initialize(
    @value : InternalFloatType,
    position : Position? = nil,
  )
    super(position)
    init_scope()
    def_natives()
  end

  def to_s_internal : ::String
    return @value.to_s
  end

  def eval_bool(scope : Scope) : ::Bool
    return @value != 0.0
  end

  # ⭐ Members
  # ---

  private def def_natives() : ::Nil
    def_native(
      name: "_+",
      returns: Object::Flt
    ) do |scope|
      self
    end

    def_native(
      name: "_-",
      returns: Object::Flt
    ) do |scope|
      Object::Flt.new(-self.value)
    end
  
    def_native(
      name: "+",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = self.value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value + other_value
      Object::Flt.new(result)
    end
  
    def_native(
      name: "-",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = self.value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value - other_value
      Object::Flt.new(result)
    end
  
    def_native(
      name: "*",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = self.value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value * other_value
      Object::Flt.new(result)
    end 
  
    def_native(
      name: "/",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = self.value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value / other_value
      Object::Flt.new(result)
    end
  end
end
