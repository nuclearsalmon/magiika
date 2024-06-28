module Magiika
  class Node::Union < TypeNode::DualTyping
    getter types : Set(TypeNodeIdent)

    def initialize(@types : Set(TypeNodeIdent))
      super(nil)
    end

    def initialize(*types : TypeNodeIdent)
      @types = Set(TypeNodeIdent).new([*types])
      super(nil)
    end
  end
end
