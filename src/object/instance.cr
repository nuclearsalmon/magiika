module Magiika
  # Instance: an instance of a Type. Everything is an Object.
  abstract class Instance < Object
    getter type : Type

    delegate is_of?, to: @type

    getter scope : Scope

    def initialize(
      @type : Type,
      position : Position? = nil
    )
      super(defining_scope: type.defining_scope, position: position)
      @scope = create_scope(position)
    end

    private def create_scope(
      position : Position?
    ) : Scope
      @type.instance_base_scope.clone(
        position: position
      )
    end
  end
end
