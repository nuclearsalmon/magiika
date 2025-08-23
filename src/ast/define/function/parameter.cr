module Magiika
  class Ast::Parameter < AstBase
    include NoEvalFeat

    getter name : ::String
    getter type : LateType?
    getter default_value : Ast?

    def initialize(
        @name : ::String,
        @type : LateType? = nil,
        @default_value : Ast? = nil,
        position : Position? = nil)
      super(position)
    end
  end
end
