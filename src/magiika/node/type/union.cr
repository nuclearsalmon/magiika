module Magiika
  class Node::Union < NodeClassBase
    getter types : Set(NodeType)

    def initialize(@types : Set(NodeType))
      super
    end
  end
end
