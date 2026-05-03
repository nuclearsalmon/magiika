module Magiika
  # Instance: an instance of a Type. Everything is an Object.
  abstract class Instance < Object
    getter type : Type

    delegate is_of?, to: @type
    delegate supertype, to: @type

    protected getter instance_scope : Scope

    def scope : Scope
      @instance_scope
    end

    def initialize(
      @type : Type,
      position : Position? = nil
    )
      super(defining_scope: type.defining_scope, position: position)

      # create instance scope
      @instance_scope = @type.instance_base_scope.clone(
        position: position
      )
    end
  end
end
