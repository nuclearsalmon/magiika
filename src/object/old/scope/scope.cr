class Magiika::Scope
  getter name : ::String
  getter? position : Position?
  protected getter variables : Hash(::String, Instance::Slot)
  protected getter parent : Scope?
  def parent=(p : Scope?) : Scope?
    @parent = p
  end

  @cached_root_scope : Scope?
  @cached_root_scope_mutex : Mutex = Mutex.new

  def root_scope : Scope
    @cached_root_scope_mutex.synchronize do
      if (cached = @cached_root_scope).nil?
        root = self
        until root.parent.try { |s| root = s }.nil?; end
        @cached_root_scope = root
      end
      @cached_root_scope.not_nil!
    end
  end

  def update_cached_root_scope : Scope
    @cached_root_scope_mutex.synchronize do
      root = self
      until root.parent.try { |s| root = s }.nil?; end
      @cached_root_scope = root
      root
    end
  end

  def position : Position
    position? || Position.new
  end

  def initialize(
    @name : ::String,
    @position : Position? = nil,
    @parent : Scope? = nil,
    @variables = Hash(::String, Object::Slot).new
  )
  end

  def clone(
    name : ::String = @name,
    position : Position? = @position,
    parent : Scope? = @parent,
    variables : Hash(::String, Object::Slot) = @variables
  ) : self

    self.class.new(name, position.clone, parent, variables.dup)
  end

  def dup(
    name : ::String = @name,
    position : Position? = @position,
    *args,
    **kwargs,
  ) : self
    self.class.new(
      name: name,
      position: position,
      parent: @parent,
      variables: @variables)
  end

  def dup(
    name : ::String = @name,
    position : Position? = @position,
    parent : Scope? = @parent,
    variables : Hash(::String, Object::Slot) = @variables,
  ) : self
    Scope.new(
      name: name,
      position: position,
      parent: parent,
      variables: variables)
  end

  def self.use(
    *args,
    **kwargs,
    & : self -> R
  ) : R forall R
    instance = new(*args, **kwargs)
    yield instance
  end

  def self.with_defining_scope(
    name : ::String,
    defining_scope : Scope,
    parent : Scope? = nil,
    position : Position? = nil,
    & : self -> R
  ) : R forall R
    #what in the everloving FUCK is this doing and what
    #is its usecase???

    scope = new(
      name: name,
      position: position,
      parent: defining_scope)

    begin
      result = yield scope
    ensure
      scope.parent = parent
    end

    result
  end

  protected def ensure_slot(info : Object) : Object::Slot
    info.as?(Object::Slot) || Object::Slot.new(info, self)
  end

  # ✨ Setting values
  # ---

  # define a new value
  def define(name : ::String, info : Object) : ::Nil
    info = ensure_slot(info)

    if @variables.has_key?(name)
      raise Error::Internal.new("Variable already exists: '#{name}' in scope '#{@name}'")
    else
      @variables[name] = info
    end
  end

  def define(pairs : Hash(::String, Object))
    ::Nil
    pairs.each { |name, value| define(name, value) }
  end

  # replace an existing value
  def replace(name : ::String, info : Object) : ::Nil
    info = ensure_slot(info)

    prev_info = @variables[name]?
    if prev_info.nil?
      parent = @parent
      if !parent.nil? && parent.exist?(name)
        parent.replace(name, info)
        return
      else
        raise Error::Internal.new("Variable does not exist: '#{@name}'")
      end
    elsif prev_info.final?
      raise Error::Lazy.new("Cannot modify a constant value.")
    end

    @variables[name] = info
  end

  def replace(pairs : Hash(::String, Object))
    ::Nil
    pairs.each { |name, value| replace(name, value) }
  end

  # assign (define or replace) a value
  def assign(name : ::String, info : Object) : ::Nil
    info = ensure_slot(info)

    prev_info = @variables[name]?
    if prev_info.nil?
      parent = @parent
      if !parent.nil? && parent.exist?(name)
        parent.assign(name, info)
        return
      end
    elsif prev_info.final?
      raise Error::Lazy.new("Cannot modify a constant value.")
    end

    @variables[name] = info
  end

  def assign(pairs : Hash(::String, Object))
    ::Nil
    pairs.each { |name, value| assign(name, value) }
  end

  def delete(name : ::String) : ::Nil
    if (variables = @variables).has_key?(name)
      variables.delete(name)
    elsif !((parent = @parent).nil?)
      parent.delete(name)
    else
      raise Error::Internal.new("Variable does not exist: '#{@name}'")
    end
  end

  # ✨ Retrieving values
  # ---

  def retrieve_here?(name : ::String) : Object::Slot?
    @variables[name]?
  end

  def retrieve_here(name : ::String) : Object::Slot?
    if (slot = retrieve_here?(name)).nil?
      raise UndefinedVariable.new(name, self)
    else
      slot
    end
  end

  def retrieve?(name : ::String) : Object::Slot?
    retrieve_here?(name) || @parent.try(&.retrieve?(name))
  end

  def retrieve(name : ::String) : Object::Slot
    if (slot = retrieve?(name)).nil?
      raise Error::UndefinedVariable.new(name, self)
    else
      slot
    end
  end

  def retrieve_type?(type : T.class) : Object::Slot? forall T
    type_name = type.type_name
    seek { |scope|
      slot = scope.retrieve?(type_name)
      if !slot.nil? && slot.value.is_of?(T)
        next slot
      end
    }
  end

  def retrieve_type(type : T.class) : Object::Slot forall T
    if (slot = retrieve_type?(type)).nil?
      raise Error::UndefinedVariable.new(type.type_name, self)
    else
      slot
    end
  end

  def retrieve_type?(type_name : ::String) : Object::Slot?
    seek { |scope|
      slot = scope.retrieve?(type_name)
      next slot if !slot.nil?
    }
  end

  def retrieve_type(type_name : ::String) : Object::Slot
    if (slot = retrieve_type?(type_name)).nil?
      raise Error::UndefinedVariable.new(type_name, self)
    else
      slot
    end
  end

  def definition?(obj : T.class) : T? forall T
    retrieve_type?(obj).try(&.value).as(T?)
  end

  def definition(obj : T.class) : T forall T
    retrieve_type(obj).value.as(T)
  end

  def definition?(type_name : ::String) : Type?
    retrieve_type?(type_name).try(&.value).as(Type?)
  end

  def definition(type_name : ::String) : Type
    retrieve_type(type_name).value.as(Type)
  end

  def union(*types : Type.class) : Object::Union
    definitions = types.map { |type| definition(type) }
    Object::Union.new(
      *definitions,
      defining_scope: self,
      position: self.position)
  end

  def union(position : Position, *types : Type.class) : Object::Union
    definitions = types.map { |type| definition(type) }
    Object::Union.new(
      *definitions,
      defining_scope: self,
      position: position)
  end

  def retrieve_fn?(
    name : ::String,
    args : Array(Object::Argument),
    deep_analysis : ::Bool = false,
  ) : {MatchResult, {Object::Function, Hash(::String, Object)}?}?
    variable = retrieve?(name)
    return nil unless variable.is_a?(Object::Function)

    match_result, param_hash = variable.match_args(args, deep_analysis)
    return deep_analysis ? {match_result, {variable, param_hash}} : ::Nil
  end

  def retrieve_fn(
    name : ::String,
    args : Array(Object::Argument),
    deep_analysis : ::Bool = false,
  ) : {MatchResult, {Object::Function, Hash(::String, Object)}?}
    fn = retrieve_fn?(name, args, deep_analysis)
    return fn unless fn.nil?
    raise Error::UndefinedVariable.new(name, self)
  end

  # ✨ Iterate or locate
  # ---

  def exist?(name : ::String) : ::Bool
    @variables.has_key?(name) || ((parent = @parent).nil? ? false : parent.exist?(name))
  end

  def exist_here?(name : ::String) : ::Bool
    @variables.has_key?(name)
  end

  def exist_elsewhere?(name : ::String) : ::Bool
    (parent = @parent).nil? ? false : parent.exist?(name)
  end

  private class ScopeIterator
    include Iterator(Scope)

    @scope : Scope?

    def initialize(@scope : Scope)
    end

    def next
      scope = @scope
      if scope.nil?
        stop
      else
        @scope = scope.parent
        scope
      end
    end
  end

  def seek(&block : Scope -> R) : R? forall R
    ScopeIterator.new(self).each { |scope|
      r = block.call(scope)
      return r unless r.nil?
    }
  end

  def seek : Iterator(Scope)
    ScopeIterator.new(self)
  end

  def check_resource_limits! : ::Nil
  end

  def each_slot(&block : (::String, Object::Slot) -> _) : ::Nil
    @variables.each { |name, slot|
      result = block.call(name, slot)
      return result unless result.nil?
    }
    @parent.try(&.each_slot(&block))
  end

  def surface_slots(type_filter : Set(Object | Object.class)?) : Hash(String, Object::Slot)
    surface_slots = Hash(String, Object::Slot).new
    each_slot { |name, slot|
      surface_slots[name] = slot unless surface_slots.has_key?(name)
      next nil  # signal to not break the loop
    }

    # remove slots that don't match the type filter
    surface_slots.select! { |name, slot|
      type_filter.nil? || \
      type_filter.empty? || \
      type_filter.any? { |t| slot.value.is_of?(t) }
    }
  end
end
