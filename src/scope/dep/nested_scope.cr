module Magiika
  class Scope::Nested < Scope::Standalone
    @parent : Scope

    def initialize(
        name : ::String,
        @parent : Scope,
        position : Position? = nil,
        variables : Hash(::String, Object::Slot) = \
          Hash(::String, Object::Slot).new)
      super(
        name: name,
        position: position,
        variables: variables)
    end

    def dup(
        name : ::String = @name, 
        parent : Scope = @parent, 
        position : Position? = @position, 
        variables : Hash(::String, Object::Slot) = @variables) : self
      self.class.new(
        name: name,
        parent: parent,
        position: position,
        variables: variables)
    end

    # ✨ Setting values
    # ---

    # *define* is the same as in *Scope::Standalone*

    def replace(name : ::String, info : Object::Slot) : ::Nil
      if (prev_info = @variables[name]?).nil?
        @parent.replace(name, info)
      else
        if prev_info.final?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        unreference_type(prev_info.value)
        reference_type(info.value)
        @variables[name] = info
      end
    end

    def assign(name : ::String, info : Object::Slot) : ::Nil
      prev_info = @variables[name]?
      if prev_info.nil?
        if @parent.exist?(name)
          @parent.assign(name, info)
          return
        end
      else
        if prev_info.final?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        unreference_type(prev_info.value)
      end

      reference_type(info.value)
      @variables[name] = info
    end


    # ✨ Retrieving values
    # ---

    def retrieve?(name : ::String) : Object::Slot?
      @variables[name]? || @parent.retrieve?(name)
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : ::String) : ::Bool
      @variables.has_key?(name) || @parent.exist?(name)
    end

    def exist_here?(name : ::String) : ::Bool
      @variables.has_key?(name)
    end

    def exist_elsewhere?(name : ::String) : ::Bool
      @parent.exist?(name)
    end

    def seek(&block : Scope -> R) : R? forall R
      (result = block.call(self)).nil? ? @parent.seek(&block) : result
    end

    def each_value(&block : Object::Slot -> ::Nil) : ::Nil
      @variables.each_value { |info|
        block.call(info)
      }
    end

    def find_base_scope : Scope::Standalone
      @parent.find_base_scope
    end
  end
end
