module Magiika
  class Node::Union < TypeNode
    include Typing::EvalsToType

    Typing.instance_typing_feat

    @types : FlexibleSet(Typing::Type)
    getter types

    def initialize(
        @types : Set(Typing::Type),
        position : Position? = nil)
      super(position)
    end

    def initialize(
        *types : Typing::Type,
        position : Position? = nil)
      @types = Magiika::FlexibleSet(Typing::Type).new([] of Typing::Type)#([*types] of Typing::Type)
      types.each { |_type|
        @types << _type.as(Typing::Type)
      }
      super(position)
    end
  end
end
