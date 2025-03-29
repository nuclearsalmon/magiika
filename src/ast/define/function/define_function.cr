module Magiika
  class Ast::DefineFunction < AstBase
    getter? static : ::Bool
    getter name : ::String
    getter parameters : Array(Ast::Parameter)
    getter statements : Array(Ast)?
    getter returns : Ast?
    getter access : Access
    
    def abstract? : ::Bool
      @statements.nil?
    end

    def initialize(
        @static : ::Bool,
        @name : ::String,
        @parameters : Array(Ast::Parameter),
        @statements : Array(Ast)? = nil,
        @returns : Ast? = nil,
        @access : Access = Access::Public,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Object
      parameters : Array(Object::Parameter) = @parameters.map { |ast_parameter|
        Object::Parameter.from(ast_parameter, scope)
      }
      returns = @returns.try(&.eval(scope))

      if (statements = @statements).nil?
        function = Object::AbstractFunction.new(
          defining_scope: scope,
          static: @static,
          name: @name,
          parameters: parameters,
          returns: returns,
          position: @position)
      else
        function = Object::RuntimeFunction.new(
          statements: statements,
          defining_scope: scope,
          static: @static,
          name: @name,
          parameters: parameters,
          returns: returns,
          position: @position)
      end

      slot = Object::Slot.new(
        value: function,
        final: true,
        type: function,
        access: @access)

      scope.define(@name, slot)
      return function
    end
  end
end