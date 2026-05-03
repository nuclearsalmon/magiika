module Magiika
  # Type: a type that can be instantiated into an Instance.
  # Everything is an Object.
  abstract class Type < Object
    private macro type_recursive
      macro inherited
        def superclass_t : Magiika::Type?
          {% verbatim do %}
            {{ @type.superclass }}
          {% end %}
        end

        type_recursive
      end
    end
    type_recursive

    protected getter instance_base_scope : Scope  # base for scope of instance
    getter superclass : Type? = nil

    def initialize(
      defining_scope : Scope,
      superclass : Type? = nil,
      position : Position? = nil
    )
      super(defining_scope, position)

      # define instance scope
      if superclass.nil?
        @instance_base_scope = Scope.new(
          "#{type_name}__base")
      else
        @superclass = superclass
        superscope = superclass.instance_base_scope
        @instance_base_scope = Scope.new(
          "#{type_name}__base",
          superscope)
      end
    end

    abstract def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance
  end
end
