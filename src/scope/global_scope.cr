class Magiika::Scope::Global < Magiika::Scope
  SCOPE_NAME = "global"

  def root_scope : self
    self
  end

  def update_cached_root_scope : self
    self
  end

  def initialize(
    name : ::String = SCOPE_NAME,
    position : Position? = nil,
    parent : Scope? = nil,
    variables : Hash(::String, Object::Slot) = Hash(::String, Object::Slot).new,
  )
    # validate (we need to offer these to confirm with Scope,
    # but that doesn't mean we have to accept them)
    raise Error::Internal.new(
      "Global scope name cannot be changed."
    ) if name != SCOPE_NAME

    raise Error::Internal.new(
      "Global scope cannot have a parent."
    ) if parent != nil

    # defer to Scope
    super(
      name: SCOPE_NAME,
      position: position,
      parent: nil,
      variables: variables)

    # define top level
    def_toplevel
  end

  private def def_toplevel : ::Nil
    # primitives
    #type_sources : Tuple(Type) = {
    types : Enumerable(Type) = {
      Object::Function.new(self),
      Object::Bool.new(self),
      #Object::Flt.new(self),
      #Object::List.new(self),
      #Object::Nil.new(self),
      #Object::Str.new(self),
    }.as(Enumerable(Type))

    # preliminary initialization of types
    #types : Enumerable(Type) = type_sources.map { |type|
    #  type.as(Type.class).new(
    #    global_scope: self.as(Scope::Global),
    #    position: nil.as(Position?)
    #  )
    #}

    # place in global scope
    define(types.to_h { |type| {type.type_name, type} })

    # complete definition of types
    types.each { |type| type.define }
  end
end
