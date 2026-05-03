class Magiika::Scope::Global < Magiika::Scope
  SCOPE_NAME = "global"

  getter security_config : SecurityConfig

  def root_scope : self
    self
  end

  def update_cached_root_scope : self
    self
  end

  # for compatibility with Scope#clone
  protected def initialize(
    name : ::String = SCOPE_NAME,
    position : Position? = nil,
    parent : Scope? = nil,
    variables = Hash(::String, Object::Slot).new
  )
    if name != SCOPE_NAME
      raise Error::Lazy.new("Global scope name cannot be set")
    end
    initialize(position, parent, variables)
  end

  def initialize(
    @security_config : SecurityConfig = SecurityConfig.new
  )
    raise Error::Internal.new(
      "Global scope cannot have a parent."
    ) if parent != nil

    # defer to Scope
    super

    # define top level
    def_toplevel
  end

  def check_resource_limits! : ::Nil
    @security_config.resource_limits.check_limits!
  end

  private def def_toplevel : ::Nil
    # primitives
    types : Enumerable(Object) = {
      # todo
    }

    # place in global scope
    define(types.to_h { |type| {type.type_name, type} })

    # complete definition of types
    types.each { |type| type.complete_definition }

    # system modules (gated by module_access)
    if @security_config.module_access.visible?("SecurityInfo")
      security_info = Object::SecurityInfo.new(self, @security_config)
      define(security_info.type_name, security_info)
      security_info.define
    end
  end

  def clone(
    position : Position? = @position,
    parent : Scope? = @parent,
    variables : Hash(::String, Object::Slot) = @variables
  ) : self

    self.class.new(position.clone, parent, variables.dup)
  end
end
