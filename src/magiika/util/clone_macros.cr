module Magiika::Util
  extend self

  macro def_clone_methods
    # The `copy_with` method allows creating a new instance with altered properties.
    def copy_with(**properties)
      new_instance = self.class.new
      properties.each do |property, value|
        new_instance.instance_variable_set "@#{property}", value
      end
      new_instance
    end

    # The `clone` method creates a deep copy of the instance.
    def clone
      new_instance = self.class.new
      {% for ivar in @type.instance_vars %}
        value = @{{ivar.id}}.clone
        new_instance.instance_variable_set "@{{ivar.id}}", value
      {% end %}
      new_instance
    end
  end
end
