module Magiika
  class Scope::Compound < Scope
    @scopes : Array(Scope)

    def initialize(name : ::String, @scopes : Array(Scope), position : Position? = nil)
      super(name, position)
      raise Error::Internal.new("Compound scope must contain at least two scopes.") if @scopes.size < 2
    end

    def dup(
      name : ::String = @name, 
      position : Position? = @position,
      *args,
      **kwargs) : self
      self.class.new(name, @scopes, position)
    end

    def cleanup : ::Nil; end


    # ✨ Setting values
    # ---

    def define(name : ::String, info : Object::Slot) : ::Nil
      if exist?(name)
        raise Error::Internal.new("Variable already exists: \'#{@name}\'")
      else
        @scopes[0].define(name, info)
      end
    end

    def replace(name : ::String, info : Object::Slot) : ::Nil
      scope = find_var_scope(name)
      if scope.nil?
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      else
        scope.replace(name, info)
      end
    end

    def assign(name : ::String, info : Object::Slot) : ::Nil
      scope = find_var_scope(name)
      if scope.nil?
        @scopes[0].assign(name, info)
      else
        scope.assign(name, info)
      end
    end

    def delete(name : ::String) : ::Nil
      scope = find_var_scope(name)
      if scope.nil?
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      else
        scope.delete(name)
      end
    end

    # ✨ Retrieving values
    # ---

    def retrieve?(name : ::String) : Object::Slot?
      @scopes.each { |scope|
        info = scope.retrieve?(name)
        return info unless info.nil?
      }
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : ::String) : ::Bool
      @scopes.each { |scope|
        return true if scope.exist?(name)
      }
      return false
    end

    def exist_here?(name : ::String) : ::Bool
      exist?(name)
    end

    private def find_var_scope(name : ::String) : Scope?
      @scopes.each { |scope|
        return scope if scope.exist?(name)
      }
    end

    def seek(&block : Scope -> R) : R? forall R
      @scopes.each { |scope|
        result = scope.seek(&block)
        break result unless result.nil?
      }
    end

    def each_value(&block : Object::Slot -> ::Nil) : ::Nil
      @scopes.each { |scope|
        scope.each_value(&block)
      }
    end

    def find_base_scope : Scope::Standalone
      raise Error::Internal.new("Compound scope cannot be empty.") if @scopes.size < 1
      @scopes[-1].find_base_scope
    end
  end
end