module Magiika
  alias InternalIntegerType = Int32
  alias InternalFloatType = Float32
  alias InternalNumberType = InternalIntegerType | InternalFloatType

  module Psuedo::Number
    abstract def value : InternalNumberType
  end

  alias Object::Number = Object::Int | Object::Flt
  
  NUMBER_UNION = Object::Union.new(
    Object::Flt, 
    Object::Int
  )
end