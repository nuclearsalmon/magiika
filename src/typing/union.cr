module Magiika
  class Node::Union < InstTypeNode
    @type_metas : Set(TypeMeta)
    getter type_metas

    def initialize(
        @type_metas : Set(TypeMeta),
        position : Position? = nil)
      super(position)
    end
  
    def initialize(
        *type_metas : TypeMeta,
        position : Position? = nil)
      @type_metas = Set(TypeMeta).new(type_metas)
      super(position)
    end
  end
end
