module Magiika
  class Scope::Standalone < Scope
    protected getter variables : Hash(String, Node::Meta)

    def initialize(
        name : String,
        position : Position? = nil,
        @variables : Hash(String, Node::Meta) = \
          Hash(String, Node::Meta).new)
      super(name, position)
    end

    def cleanup : ::Nil
      @variables.each_value { |meta|
        unreference_type(meta.value)
      }
    end


    # ✨ Setting values
    # ---

    def define(name : String, meta : Node::Meta) : ::Nil
      if @variables.has_key?(name)
        raise Error::Internal.new("Variable already exists: \'#{@name}\'")
      else
        reference_type(meta.value)
        @variables[name] = meta
      end
    end

    def replace(name : String, meta : Node::Meta) : ::Nil
      prev_meta = @variables[name]?
      if prev_meta.nil?
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      end

      if prev_meta.const?
        raise Error::Lazy.new("Cannot modify a constant value.")
      end

      unreference_type(prev_meta.value)
      reference_type(meta.value)
      @variables[name] = meta
    end

    def assign(name : String, meta : Node::Meta) : ::Nil
      prev_meta = @variables[name]?
      unless prev_meta.nil?
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
      @variables[name]?
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : String) : ::Bool
      @variables.has_key?(name)
    end

    def exist_here?(name : String) : ::Bool
      exist?(name)
    end

    def find_base_scope : Scope::Standalone
      return self
    end
  end
end
