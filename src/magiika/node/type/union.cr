module Magiika
  class Node::Union < NodeClassBase
    getter types : Set(NodeType)

    def initialize(@types : Set(NodeType))
      super(nil)
    end

    def initialize(*types : NodeType)
      @types = Set(NodeType).new([*types])
      super(nil)
    end
  end
end
