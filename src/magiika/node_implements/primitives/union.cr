module Magiika
  class Node::Union < TypeNodeClass::DualTyping
    getter types : Set(Psuedo::TypeNodeIdent)

    def initialize(@types : Set(Psuedo::TypeNodeIdent))
      super(nil)
    end

    def initialize(*types : Psuedo::TypeNodeIdent)
      @types = Set(Psuedo::TypeNodeIdent).new([*types])
      super(nil)
    end
  end
end
