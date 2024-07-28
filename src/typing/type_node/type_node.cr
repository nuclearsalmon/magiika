module Magiika::Typing
  module EvalsToType
    abstract def eval_type(scope : Scope) : Typing::Type
  end

  module Type
    abstract def type_id : Typing::TypeID
    abstract def type_name : ::String
    abstract def superclass? : Typing::Type?

    abstract def inherits_from_type?(other : Typing::Type) : ::Bool
    abstract def inherits_from_type!(other : Typing::Type) : ::Nil
    abstract def fits_exact_type?(other : Typing::Type) : ::Bool
    abstract def fits_exact_type!(other : Typing::Type) : ::Nil
    abstract def fits_type?(other : Typing::Type) : ::Bool
    abstract def fits_type!(other : Typing::Type) : ::Nil
  end

  module RegistrableType
    include Type

    abstract def register_type : Typing::TypeID
    abstract def unregister_type : ::Nil
  end
end

module Magiika
  abstract class TypeNode < Node
    Typing.class_typing_feat

    private macro recursive_inherited
      macro inherited
        {% verbatim do %}
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
        {% end %}

        recursive_inherited
      end
    end

    recursive_inherited
  end
end
