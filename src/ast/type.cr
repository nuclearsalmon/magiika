module Magiika
  class Ast::Type < AstBase
    getter type_name : ::String

    def initialize(
      @type_name : ::String,
      position : Position
    )
      super(position)
    end

    def eval(scope : Scope) : Magiika::Type
      scope.definition(@type_name)
    end
  end
end
