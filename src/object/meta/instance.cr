module Magiika
  abstract class Instance < ObjectT
    getter type : Type
    protected getter instance_scope : Scope

    def initialize(@type : Type, position : Position? = nil)
      super(position: position)

      # create instance scope
      @instance_scope = @type.new_instance_scope
    end

    def object_name : ::String
      "#{@type.object_name}~"
    end
  end
end
