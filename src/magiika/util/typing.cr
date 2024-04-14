module Magiika
  extend self

  alias NodeType = Node | Node.class |
    NodeClassBase | NodeClassBase.class |
      NodeStructBase | NodeStructBase.class

  def node_is_a?(a : NodeType, b : NodeType) : ::Bool
    a.node_is_a?(b) || b.node_is_a?(a)
  end

  def node_inherits_from(a : NodeType, b : NodeType) : ::Bool
    return a.inherits_from(b) if a.is_a?(NodeClassBase)
    false
  end
end
