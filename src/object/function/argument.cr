module Magiika
  class Object::Argument < Object
    getter value : AnyObject
    getter name : ::String?

    def initialize(
      @value : AnyObject,
      @name : ::String? = nil,
      position : Position? = nil
    )
      super(position)
    end

    def self.from(ast_argument : Ast::Argument, scope : Scope) : Object::Argument
      Object::Argument.new(
        value: ast_argument.value.eval(scope),
        name: ast_argument.name,
        position: ast_argument.position
      )
    end

    def is_of?(other : ::Object) : ::Bool
      if other.is_a?(typeof(self)) || other.is_a?(Object::Parameter)
        unless self.name.nil?
          return false if self.name != other.name
        end
        if other.is_a?(Object::Parameter)
          other = other.as(Object::Parameter)
          return true if other.type.nil?
          return other.type.try { |t| self.value.is_of?(t) } || false
        else
          return self.value.is_of?(other)
        end
      else
        super(other)
      end
    end
  end
end
