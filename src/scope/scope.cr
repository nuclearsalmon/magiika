class Magiika::Scope
  property name : ::String
  getter? position : Position?
  protected getter variables : Hash(::String, Object::Slot)
  @parent : Scope?

  def position : Position
    position? || Position.new
  end

  def initialize(
    @name : ::String,
    @position : Position? = nil,
    @parent : Scope? = nil,
    @variables : Hash(::String, Object::Slot) = Hash(::String, Object::Slot).new,
  )
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

  # ✨ Setting values
  # ---

  # define a new value
  def define(name : ::String, info : Object::Slot) : ::Nil
    if @variables.has_key?(name)
      raise Error::Internal.new("Variable already exists: '#{@name}'")
    else
      @variables[name] = info
    end
  end

  def define(name : ::String, value : AnyObject) : ::Nil
    define(name, Object::Slot.new(value))
  end

  def define(pairs : Hash(::String, AnyObject | Object::Slot))
    ::Nil
    pairs.each { |name, value| define(name, value) }
  end

  # replace an existing value
  def replace(name : ::String, info : Object::Slot) : ::Nil
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

  def replace(name : ::String, value : AnyObject) : ::Nil
    replace(name, Object::Slot.new(value))
  end

  def replace(pairs : Hash(::String, AnyObject | Object::Slot))
    ::Nil
    pairs.each { |name, value| replace(name, value) }
  end

  # assign (define or replace) a value
  def assign(name : ::String, info : Object::Slot) : ::Nil
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

  def assign(name : ::String, value : AnyObject) : ::Nil
    assign(name, Object::Slot.new(value))
  end

  def assign(pairs : Hash(::String, AnyObject | Object::Slot))
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

  def retrieve?(name : ::String) : Object::Slot?
    @variables[name]? || @parent.try(&.retrieve?(name))
  end

  def retrieve(name : ::String) : Object::Slot
    obj = retrieve?(name)
    return obj unless obj.nil?
    raise Error::UndefinedVariable.new(name, self)
  end

  def retrieve_fn?(
    name : ::String,
    args : Array(Object::Argument),
    deep_analysis : ::Bool = false,
  ) \
     : {MatchResult, {Object::Function, Hash(::String, Object)}?}?
      variable = retrieve?(name)
      return nil unless variable.is_a?(Object::Function)

      match_result, param_hash = variable.match_args(args, deep_analysis)
      return deep_analysis ? {match_result, {variable, param_hash}} : ::Nil
    end

  def retrieve_fn(
    name : ::String,
    args : Array(Object::Argument),
    deep_analysis : ::Bool = false,
  ) \
     : {MatchResult, {Object::Function, Hash(::String, Object)}?}
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

  def seek(&block : Scope -> R) : R? forall R
    if (result = block.call(self)).nil?
      @parent.try(&.seek(&block))
    else
      result
    end
  end

  def each_slot(&block : (::String, Object::Slot) -> _) : ::Nil
    @variables.each { |name, slot|
      result = block.call(name, slot)
      return result unless result.nil?
    }
    @parent.try(&.each_slot(&block))
  end

  def surface_slots(type_filter : Set(AnyObject)?) : Hash(String, Object::Slot)
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

  def find_base_scope : Scope
    (parent = @parent).nil? ? self : parent.find_base_scope
  end
end
