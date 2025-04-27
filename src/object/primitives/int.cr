class Magiika::Object::Int < Magiika::PrimitiveObject
  include Psuedo::Number

  getter value : InternalIntegerType


  def_natives()


  def initialize(
    @value : InternalIntegerType,
    position : Position? = nil,
  )
    super(position)
  end

  def to_s_internal : ::String
    return @value.to_s
  end

  def eval_bool(scope : Scope) : ::Bool
    return @value != 0
  end

  # ⭐ Members
  # ---

  private def self.def_natives : ::Nil
    def_native(
      name: "_+",
      returns: Object::Int
    ) do |scope|
      scope.retrieve(SELF_NAME).value.as(Object::Int)
    end

    def_native(
      name: "_-",
      returns: Object::Int
    ) do |scope|
      Object::Int.new(-(scope.retrieve(SELF_NAME).value.as(Object::Int).value))
    end

    def_native(
      name: "+",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value + other_value
      Object::Int.new(result)
    end

    def_native(
      name: "-",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value - other_value
      Object::Int.new(result)
    end

    def_native(
      name: "*",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value * other_value
      Object::Int.new(result)
    end

    def_native(
      name: "/",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value / other_value
      Object::Int.new(result.to_i32)
    end
  end
end
