module Magiika
  class Object::Parameter < Object
    getter name : ::String
    getter type : Type?
    getter default_value : Object?

    def initialize(
      defining_scope : Scope,
      @name : ::String,
      @type : Type? = nil,
      @default_value : Object? = nil,
      position : Position? = nil
    )
      super(defining_scope: defining_scope, position: position)
    end

    def self.from(ast_parameter : Ast::Parameter, scope : Scope) : Object::Parameter
      Object::Parameter.new(
        defining_scope: scope,
        name: ast_parameter.name,
        type: ast_parameter.type.try(&.eval(scope)),
        default_value: ast_parameter.default_value \
          .try(&.eval(scope)),
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
