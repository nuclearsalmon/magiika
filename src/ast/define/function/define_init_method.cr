module Magiika
  class Ast::DefineInitMethod < Ast::DefineFunction
    def initialize(
      parameters : Array(Ast::Parameter),
      statements : Array(Ast),
      access : Access = Access::Public,
      position : Position? = nil
    )
      super(
        static: true,
        name: INIT_METHOD_NAME,
        parameters: parameters,
        statements: statements,
        returns: Object::Nil.instance,
        access: access,
        position: position
      )
    end
  end
end