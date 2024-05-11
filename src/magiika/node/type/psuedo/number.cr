module Magiika
  alias InternalIntegerType = Int32
  alias InternalFloatType = Float32
  alias InternalNumberType = InternalIntegerType | InternalFloatType

  module Node::Psuedo::Number
    abstract def value : InternalNumberType
  end

  alias Node::NumberType = Node::Int | Node::Flt

  NumberUnion = Node::Union.new(Node::Flt, Node::Int)
end