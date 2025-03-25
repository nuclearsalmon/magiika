module Magiika
  class Scope::Standalone < Scope
    protected getter variables : Hash(::String, Object::Slot)

    def initialize(
        name : ::String,
        position : Position? = nil,
        @variables : Hash(::String, Object::Slot) = \
          Hash(::String, Object::Slot).new)
      super(name, position)
    end

    def dup(
      name : ::String = @name,
      position : Position? = @position,
      *args,
      **kwargs) : self
      dup(name, position, @variables)
    end

    def dup(
        name : ::String = @name,
        position : Position? = @position, 
        variables : Hash(::String, Object::Slot) = @variables) : self
      Standalone.new(
        name: name,
        position: position,
        variables: variables)
    end

    def cleanup : ::Nil
      @variables.each_value { |info|
        unreference_type(info.value)
      }
    end


    # ✨ Setting values
    # ---

    def define(name : ::String, info : Object::Slot) : ::Nil
      if @variables.has_key?(name)
        raise Error::Internal.new("Variable already exists: \'#{@name}\'")
      else
        reference_type(info.value)
        @variables[name] = info
      end
    end

    def replace(name : ::String, info : Object::Slot) : ::Nil
      prev_info = @variables[name]?
      if prev_info.nil?
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      end

      if prev_info.final?
        raise Error::Lazy.new("Cannot modify a constant value.")
      end

      unreference_type(prev_info.value)
      reference_type(info.value)
      @variables[name] = info
    end

    def assign(name : ::String, info : Object::Slot) : ::Nil
      prev_info = @variables[name]?
      unless prev_info.nil?
        if prev_info.final?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        unreference_type(prev_info.value)
      end

      reference_type(info.value)
      @variables[name] = info
    end

    def delete(name : ::String) : ::Nil
      if @variables.has_key?(name)
        unreference_type(@variables[name].value)
        @variables.delete(name)
      else
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      end
    end


    # ✨ Retrieving values
    # ---

    def retrieve?(name : ::String) : Object::Slot?
      @variables[name]?
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : ::String) : ::Bool
      @variables.has_key?(name)
    end

    def exist_here?(name : ::String) : ::Bool
      exist?(name)
    end

    def each_value(&block : Object::Slot -> ::Nil) : ::Nil
      @variables.each_value { |info|
        block.call(info)
      }
    end

    def find_base_scope : Scope::Standalone
      return self
    end
  end
end
