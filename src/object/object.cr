# AI Comment:
# Magiika::Object represents values that share a common type ID across
# all instances of their implementation. For example, all Integers
# share the same type ID, all ::Strings share the same type ID, etc.
# These are the fundamental building blocks for most values in the language.

module Magiika
  alias AnyObject = Magiika::Object | Magiika::Object.class

  abstract class Object
    include Positionable
    include IsOf

    private macro recursive_inherited_object
      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            {{ @type.name.stringify.split("::")[-1] }}
          end

          def self.superclass : Magiika::AnyObject
            {{ @type.superclass }}
          end

          recursive_inherited_object
        {% end %}
      end
    end
    recursive_inherited_object

    private module DefNative
      protected def def_native(
        name : ::String, 
        const : ::Bool = false,
        parameters : Array(Object::Parameter) = Array(Object::Parameter).new, 
        returns : AnyObject? = nil,
        access : Access = Access::Public,
        &body : Proc(Scope, Magiika::Object | Magiika::Object.class)
      ) : ::Nil
        scope = self.scope
        if (scls = self.superclass).is_a?(Magiika::Object) && scls.scope == scope
          raise Error::Internal.new("#{self} does not own this scope.")
        end

        method = Object::NativeFunction.new(
          proc: body, 
          defining_scope: self.scope,
          name: name,
          parameters: parameters,
          returns: returns)
        slot = Slot.new(
          value: method,
          final: const,
          type: Object::NativeFunction,
          access: access)
        scope.define(name, slot)
      end
    end
    include DefNative
    extend DefNative

    macro def_static_scope()
      class_getter scope = Scope.new(name: {{ @type }}.type_name)
    end

    macro def_scope()
      getter scope = Scope.new(name: {{ @type }}.type_name)
    end

    macro init_scope(scope = @scope)
      {{ scope }}.name = self.type_name
    end
    
    def_static_scope()
    def_scope()

    def initialize(@position : Position? = nil)
      init_scope(@scope)
    end

    def_native(
      name: "type",
      const: true,
      returns: self
    ) do |scope|
      self
    end

    def self.eval_bool(scope : Scope) : ::Bool
      false
    end

    def eval_bool(scope : Scope) : ::Bool
      false
    end
      
    def self.is_of!(other : Magiika::AnyObject, message : ::String? = nil) : ::Bool
      return true if self.is_of?(other)
      raise Error::Type.new(self, other, message)
    end

    def is_of!(other : Magiika::AnyObject, message : ::String? = nil) : ::Bool
      return true if self.is_of?(other)
      raise Error::Type.new(self, other, message)
    end

    def self.superclass : Magiika::AnyObject
      self # return self (Object) as the superclass
    end

    def superclass : Magiika::AnyObject
      self.class.superclass
    end

    def self.type_name : ::String
      {{ @type.name.stringify.split("::")[-1] }}
    end

    def type_name : ::String
      self.class.type_name
    end

    def self.to_s : ::String
      "#{type_name} ...\n#{pretty_inspect}"
    end

    def to_s : ::String
      "#{type_name} @ #{position.to_s} ...\n#{pretty_inspect}"
    end

    def self.to_s_internal : ::String
      type_name
    end

    def to_s_internal : ::String
      "#{type_name} @ #{position.to_s}"
    end
  end
end
