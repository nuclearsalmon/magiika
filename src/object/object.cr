# AI Comment:
# Magiika::Object represents values that share a common type ID across
# all instances of their implementation. For example, all Integers
# share the same type ID, all ::Strings share the same type ID, etc.
# These are the fundamental building blocks for most values in the language.

module Magiika
  alias AnyObject = Magiika::Object | Magiika::Object.class

  abstract class Object
    include Positionable
    
    def self.is_of?(other) : ::Bool
      raise Error::NotImplemented.new("This should have been implemented by macro.")
    end
    def is_of?(other) : ::Bool
      raise Error::NotImplemented.new("This should have been implemented by macro.")
    end
    include IsOf

    private macro recursive_inherited
      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            {{ @type.name.stringify.split("::")[-1] }}
          end

          def self.superclass : Magiika::Object
            {{ @type.superclass }}
          end

          recursive_inherited
        {% end %}
      end
    end

    recursive_inherited

    def initialize(@position : Position? = nil)
    end

    def self.as_type : Type
      Type.new(self)
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

    def self.superclass : Magiika::Object
      self # return self (Object) as the superclass
    end

    def superclass : Magiika::Object
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
