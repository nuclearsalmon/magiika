module Magiika
  abstract class TypeNode < Node
    abstract def self.type_meta : TypeMeta
    abstract def type_meta : TypeMeta

    private macro recursive_inherited
      {% verbatim do %}
        def self.type_meta : TypeMeta
          {{ TypeMeta.new(self) }}
        end

        def type_meta : TypeMeta
          self.class.type_meta
        end

        def self.superclass? : Typing::Type?
          {% if @type.superclass %}
            klass = {{ @type.superclass }}
            return klass if klass.is_a?(Typing::Type)
          {% end %}
          nil
        end

        def superclass? : Typing::Type?
          self.class.superclass?
        end

        def self.type_name : ::String
          type_name_str = "#{ {{ @type.name.stringify.split("::")[-1] }} }"

          if self.responds_to?(:type_id)
            tid = self.type_id
            type_name_str += "\##{ tid }"
          end

          type_name_str
        end

        def type_name : ::String
          "#{ {{ @type.name.stringify.split("::")[-1] }} }\##{ type_id }"
        end

        macro inherited
          recursive_inherited
        end
      {% end %}
    end

    recursive_inherited
  end

  abstract class ExtTypeNode < TypeNode
    @type_meta : TypeMeta? = nil
    getter type_meta : TypeMeta

    def type_meta : TypeMeta
      type_meta = @type_meta
      if type_meta.nil?
        raise Error::Internal.new(
          "#{self.type_name} was never assigned an instance type id.")
      end
      type_meta
    end

    def register_type : Typing::TypeID
      unless @type_id.nil?
        raise Error::Internal.new("#{self.type_name} already registered.")
      end

      type_id = Typing.register_type(self)
      @type_id = type_id
      type_id
    end

    def unregister_type : ::Nil
      type_id = @type_id
      if type_id.nil?
        raise Error::Internal.new("#{self.type_name} was never assigned an instance type id.")
      end
      Typing.unregister_type(type_id)
    end
  end
end