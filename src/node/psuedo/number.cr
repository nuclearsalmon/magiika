module Magiika
  alias InternalIntegerType = Int32
  alias InternalFloatType = Float32
  alias InternalNumberType = InternalIntegerType | InternalFloatType

  module Psuedo::Number
    #include Node
    #
    abstract def value : InternalNumberType
  end

  alias Node::Number = Node::Int | Node::Flt
  NUMBER_UNION = Node::Union.new(
    Node::Flt.type_meta, 
    Node::Int.type_meta)
end