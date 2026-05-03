module Magiika
  class Scope
    protected alias Slots = SlotInstance | Set(SlotInstance)
    @variables : Hash(::String, Slots)
    @mutex = Mutex.new 

    abstract def get_global_scope : GlobalScope

    protected def ensure_slot(obj : Object) : SlotInstance
      info.as?(SlotInstance) || SlotInstance.new(obj, self)
    end

    # -✧ Getting values ---

    # resolve a name, get it and the scope that owns it
    abstract def retrieve(name : ::String) : {Object, Scope}

    def resolve(name : ::String, expected : T) : {T, Scope} forall T
      obj = resolve(name)
      raise Error::Type.new(obj.class, T) unless obj.is_a?(T)
      return {obj.as(T), self}
    end

    def definition(type_class : T.class) : T forall T
      type = resolve(type_class.object_name)
      raise Error::Type.new(type.class, T) unless type.is_a?(T)
      return type.as(T)
    end

    # -✧ Setting values ---

    # define a new value
    def define(name : ::String, slot : SlotInstance) : ::Nil
      @mutex.synchronize do
        raise Error::RedefineVariable.new(name) if @variables.has_key?(name)
        @variables[name] = slot
      end
    end

    # update an existing value, respecting its slot
    abstract def update(name : ::String, obj : Object) : ::Nil
  end
end
