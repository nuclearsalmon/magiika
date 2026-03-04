module Magiika
  # Object: the base for all runtime, not AST, nodes.
  # Everything is an Object...or an AST node. Sometimes both (primitives).
  class Object
    include Positionable
    include IsOf

    private macro object_recursive
      def self.type_name : ::String
        {% verbatim do %}
          {{ @type.name.stringify.split("::")[-1] }}
        {% end %}
      end

      def type_name : ::String
        self.class.type_name
      end
      
      macro inherited
        object_recursive
      end
    end
    object_recursive

    getter defining_scope : Scope

    def scope : Scope
      Scope.new(type_name)  # FIXME: Properly implement this
    end

    def initialize(
      @defining_scope : Scope,
      @position : Position? = nil)
    end

    def eval_bool(scope : Scope) : ::Bool
      true
    end
    
    # NOTE: extend is_of module with magiika-specific error handling
    def is_of!(other : Magiika::Object, message : ::String? = nil) : ::Bool
      self_type : Type = self.is_a?(Instance) ? self.type : self.as(Type)

      return true if self_type.is_of?(other)
      raise Error::Type.new(self_type, other, message)
    end

    def self.type_name : ::String
      raise NotImplementedError.new("type_name is not implemented for #{{{ @type }}}")
    end

    def type_name : ::String
      raise NotImplementedError.new("type_name is not implemented for #{{{ @type }}}")
    end

    def to_s : ::String
      "#{type_name} @ #{position} ...\n#{pretty_inspect}"
    end

    def to_s_internal : ::String
      "#{type_name} @ #{position}"
    end
  end
end
