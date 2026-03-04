module Magiika
  alias InternalIntegerType = Int32
  alias InternalFloatType = Float32
  private alias InternalNumberType = InternalIntegerType | InternalFloatType

  module Psuedo::Number
    abstract def value : InternalNumberType
  end

  NUMBER_TYPES = {
    Object::Flt,
    Object::Int
  }
end