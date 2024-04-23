module Magiika
  extend self

  def node_is_a?(a : NodeAny, b : NodeAny) : ::Bool
    a.node_is_a?(b) || b.node_is_a?(a)
  end

  def node_inherits_from(a : NodeAny, b : NodeAny) : ::Bool
    return a.node_inherits_from(b) if a.is_a?(NodeClassBase)
    false
  end
end
