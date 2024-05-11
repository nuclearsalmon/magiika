module Magiika
  # Node as a type representation
  alias NodeType = NodeClassBase.class | NodeStructBase.class | Node::Union # | Node::Class
  # Node as an instance
  alias NodeObj = NodeClassBase | NodeStructBase
  # Node as either a type representation or an instance
  alias NodeAny = NodeObj | NodeType
end