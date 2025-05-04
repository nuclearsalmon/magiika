class Magiika::Object::IntType < Magiika::PrimitiveType
  include Psuedo::Number

  def initialize(global_scope : Scope, position : Position? = nil)
    super(global_scope: global_scope, position: position)
  end

  protected def create_instance(value : InternalIntegerType, position : Position? = nil) : Object::Int
    Object::Int.new(cls: self, value: value, position: position)
  end
end

class Magiika::Object::Int < Magiika::PrimitiveInstance
  include Psuedo::Number

  getter value : InternalIntegerType

  def initialize(
    @cls : IntType,
    @value : InternalIntegerType,
    position : Position? = nil,
  )
    super(cls: @cls, position: position)
    setup_natives
  end

  def to_s_internal : ::String
    return @value.to_s
  end

  def eval_bool(scope : Scope) : ::Bool
    return @value != 0
  end

  private def setup_natives
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
      Object::Int.new(cls: @cls, value: -(scope.retrieve(SELF_NAME).value.as(Object::Int).value))
    end

    def_native(
      name: "+",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value + other_value
      Object::Int.new(cls: @cls, value: result)
    end

    def_native(
      name: "-",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value - other_value
      Object::Int.new(cls: @cls, value: result)
    end

    def_native(
      name: "*",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value * other_value
      Object::Int.new(cls: @cls, value: result)
    end

    def_native(
      name: "/",
      parameters: [Object::Parameter.new("other", NUMBER_UNION)],
      returns: Object::Int
    ) do |scope|
      self_value = scope.retrieve(SELF_NAME).value.as(Object::Int).value.to_i32
      other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
      result = self_value / other_value
      Object::Int.new(cls: @cls, value: result.to_i32)
    end
  end
end
