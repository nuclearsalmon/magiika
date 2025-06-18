module Magiika
  abstract class SingletonType < UniqueType
    private class SingletonInstance < Instance
    end

    getter instance : Instance = SingletonInstance.new(type: DummyType.new)
    delegate type, scope, is_of?, to: @instance

    def initialize(
      defining_scope : Scope, 
      superclass : Type? = nil,
      position : Position? = nil
    )
      super(defining_scope, superclass, position)
      @instance = SingletonInstance.new(
        type: self,
        position: position)
    end

    protected def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance
      @instance
    end
  end
end
