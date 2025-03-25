module Magiika
  class Object::Parameter < Object
    getter name : ::String
    getter type : AnyObject?
    getter default_value : AnyObject?

    def initialize(
        @name : ::String,
        @type : AnyObject? = nil,
        @default_value : AnyObject? = nil,
        position : Position? = nil)
      super(position)
    end

    def self.from(ast_parameter : Ast::Parameter, scope : Scope) : Object::Parameter
      Object::Parameter.new(
        name: ast_parameter.name,
        type: ast_parameter.type.try(&.eval(scope)),
        default_value: ast_parameter.default_value.try(&.eval(scope)),
        position: ast_parameter.position
      )
    end

    def is_of?(other : ::Object) : ::Bool
      if other.is_a?(typeof(self))
        self_type, other_type = self.type, other.type
        
        return (
          (self.name == other.name) && 
          (self_type.nil? || (!other_type.nil? && self_type.is_of?(other_type)))
        )
      else
        super(other)
      end
    end
  end
end