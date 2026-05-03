module Magiika
  abstract class SingletonType < Type
    private class SingletonInstance < Instance
    end

    getter type_id : Typing::TypeID
    getter instance : Instance
    delegate type, scope, is_of?, to: @instance

    def initialize(
      defining_scope : Scope, 
      superclass : Type? = nil,
      position : Position? = nil
    )
      @instance = uninitialized SingletonInstance
      super(defining_scope, superclass, position)
      @type_id = Typing.aquire_id
      @instance = SingletonInstance.new(type: self, position: position)
    end

    def finalize : ::Nil
      Typing.release_id(@type_id)
    end

    protected def create_instance(*args, position : Position? = nil, **kwargs) : Instance
      instance
    end
  end
end
