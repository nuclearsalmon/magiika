module Magiika
  class Ast::DefineVariable < AstBase
    getter? static : ::Bool
    @name : ::String
    @value : Ast
    @type : Ast?
    @access : Access

    def initialize(
        @static : ::Bool,
        @name : ::String,
        @value : Ast,
        @type : Ast? = nil,
        @access : Access = Access::Public,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      value = @value.eval(scope)
      type = @type.try(&.eval(scope))

      slot = Object::Slot.new(
        value: value,
        type: type,
        access: @access)

      scope.define(@name, slot)
      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
