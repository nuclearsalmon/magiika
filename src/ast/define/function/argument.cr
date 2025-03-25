module Magiika
  class Ast::Argument < AstBase
    include NoEvalFeat

    getter value : Ast
    getter name : ::String?

    def initialize(
      @value : Ast,
      @name : ::String? = nil,
      position : Position? = nil
    )
      super(position)
    end
  end
end
