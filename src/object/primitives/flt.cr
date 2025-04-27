class Magiika::Object::Flt < Magiika::PrimitiveObject
  include Magiika::Psuedo::Number

  getter value : InternalFloatType

  def_natives()

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

  private def self.def_natives() : ::Nil
    def_native(
      name: "_+",
      returns: Object::Flt
    ) do |scope|
      scope.retrieve(SELF_NAME).value.as(Object::Flt)
    end

    def_native(
      name: "_-",
      returns: Object::Flt
    ) do |scope|
      Object::Flt.new(-(scope.retrieve(SELF_NAME).value.as(Object::Flt).value))
    end
  
    def_native(
      name: "+",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Flt).value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value + other_value
      Object::Flt.new(result)
    end
  
    def_native(
      name: "-",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Flt).value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value - other_value
      Object::Flt.new(result)
    end
  
    def_native(
      name: "*",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Flt).value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value * other_value
      Object::Flt.new(result)
    end 
  
    def_native(
      name: "/",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Flt
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Flt).value.to_f32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
      result = self_value / other_value
      Object::Flt.new(result)
    end
  end
end
