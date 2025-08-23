module Magiika
  class Ast::LateType < AstBase
    @type_name : ::String
    @type : Type.class | Nil = nil

    def initialize(
      @type_name : ::String,
      position : Position
    )
      super(position)
    end

    def initialize(
      @type : Type.class,
      position : Position
    )
      @type_name = type.type_name
      super(position)
    end

    def eval(scope : Scope) : Type
      slot = scope.retrieve_type(@type_name)
      @type.try { |type| slot.value.is_of!(type) }
      slot.value
    end
  end
end
