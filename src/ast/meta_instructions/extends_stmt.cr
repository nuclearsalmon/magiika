module Magiika
  class Ast::ExtendsStmt < AstBase
    include NoEvalFeat

    getter name : ::String

    def initialize(
        @name : ::String,
        position : Position? = nil)
      super(position)
    end
  end
end
