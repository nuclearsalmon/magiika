module Magiika
  abstract class SubScope < Scope
    @cached_global_scope : GlobalScope? = nil
    @cached_global_scope_mutex = Mutex.new
    @parent_scope : Scope

    def get_global_scope : GlobalScope
      @cached_global_scope_mutex.synchronize do
        cached_global_scope = @cached_global_scope
        return cached_global_scope unless cached_global_scope.nil?

        cached_global_scope = parent.get_global_scope
        @cached_global_scope = cached_global_scope
        return cached_global_scope
      end
    end

    # -✧ Getting values ---

    def retrieve(name : ::String) : {Object, Scope}
      obj = @variables[name]?
      return obj unless obj.nil?
      return @parent_scope.resolve(name, expected)
    end

    # -✧ Setting values ---

    def update(name : ::String, obj : Object) : ::Nil
      @mutex.synchronize do
        unless (slot = @variables[name]?).nil?
          slot.value = obj
          return
        end
      end

      @parent_scope.update(name, object)
    end
  end
end
