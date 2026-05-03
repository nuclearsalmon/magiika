module Magiika
  class GlobalScope < Scope
    def get_global_scope : self; self; end

    # -✧ Getting values ---

    def retrieve(name : ::String) : {Object, Scope}
      obj = @variables[name]?
      raise Error::UndefinedVariable.new(name, self) if obj.nil?
      return obj
    end

    # -✧ Setting values ---

    def update(name : ::String, obj : Object) : ::Nil
      @mutex.synchronize do
        slot = @variables[name]?
        raise Error::UndefinedVariable.new(name, self) if slot.nil?
        slot.value = obj
      end
    end
  end
end
