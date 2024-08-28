module Magiika
  class Scope::Nested < Scope::Standalone
    @parent : Scope

    def initialize(
        name : String,
        @parent : Scope,
        position : Position? = nil,
        variables : Hash(String, Node::Meta) = \
          Hash(String, Node::Meta).new)
      super(
        name: name,
        position: position,
        variables: variables)
    end


    # ✨ Setting values
    # ---

    # *define* is the same as in *Scope::Standalone*

    def replace(name : String, meta : Node::Meta) : ::Nil
      if (prev_meta = @variables[name]?).nil?
        @parent.replace(name, meta)
      else
        if prev_meta.const?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        unreference_type(prev_meta.value)
        reference_type(meta.value)
        @variables[name] = meta
      end
    end

    def assign(name : String, meta : Node::Meta) : ::Nil
      prev_meta = @variables[name]?
      if prev_meta.nil?
        if @parent.exist?(name)
          @parent.assign(name, meta)
          return
        end
      else
        if prev_meta.const?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        unreference_type(prev_meta.value)
      end

      reference_type(meta.value)
      @variables[name] = meta
    end


    # ✨ Retrieving values
    # ---

    def retrieve?(name : String) : Node::Meta?
      @variables[name]? || @parent.retrieve?(name)
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : String) : ::Bool
      @variables.has_key?(name) || @parent.exist?(name)
    end

    def exist_here?(name : String) : ::Bool
      @variables.has_key?(name)
    end

    def exist_elsewhere?(name : String) : ::Bool
      @parent.exist?(name)
    end

    def seek(&block : Scope -> R) : R? forall R
      result = @parent.seek(&block)
      return result unless result.nil?
      block.call(self)
    end

    def find_base_scope : Scope::Standalone
      @parent.find_base_scope
    end
  end
end
