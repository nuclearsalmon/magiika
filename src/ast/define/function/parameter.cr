module Magiika
  class Ast::Parameter < AstBase
    include NoEvalFeat

    getter name : ::String
    getter type : Ast?
    getter default_value : Ast?

    def initialize(
        @name : ::String,
        @type : Ast? = nil,
        @default_value : Ast? = nil,
        position : Position? = nil)
      super(position)
    end
  end
end
