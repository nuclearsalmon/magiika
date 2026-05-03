module Magiika
  class ClassInstance < Instance
    def initialize(
      type_instance : Class,
      constructor_arguments : Array(Argument)
      position : Position? = nil
    )
      super(type: type_instance, position: position)

      call_constructor(constructor_arguments)
      check_fields_initialized()
    end

    private def call_constructor(args : Array(Argument))
    end

    private def check_fields_initialized
    end
  end
end
