module Magiika
  class Scope::Global < Scope::Standalone
    def initialize(
        position : Position,
        variables : Hash(String, Node::Meta) = \
          Hash(String, Node::Meta).new)
      super(
        "global",
        position: position)
    end
  end
end
