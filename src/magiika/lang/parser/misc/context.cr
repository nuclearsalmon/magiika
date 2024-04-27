require "./token.cr"


module Magiika::Lang
  class Context
    property name : Symbol

    protected getter nodes : Array(NodeObj)?
    protected getter tokens : Array(MatchedToken)?
    protected getter sub_contexts : Hash(Symbol, Context)?

    def initialize(@name : Symbol)
    end

    def initialize(@name : Symbol,
        @nodes : Array(NodeObj)?,
        @tokens : Array(MatchedToken)?,
        @sub_contexts : Hash(Symbol, Context)?)
    end

    def copy_with(
        name : Symbol = @name,
        nodes = @nodes,
        tokens = @tokens,
        sub_contexts = @sub_contexts)
      self.class.new(name, nodes, tokens, sub_contexts)
    end

    def clone
      self.class.new(
        @name.clone,
        @nodes.try(&.dup),
        @tokens.try(&.dup),
        @sub_contexts.try(&.clone))
    end

    # Modifying actions
    # ---

    def clear_nodes
      @nodes.try(&.clear)
    end

    def clear_tokens
      @tokens.try(&.clear)
    end

    def clear_subcontexts
      @sub_contexts.try(&.clear)
    end

    def clear
      @nodes.try(&.clear)
      @tokens.try(&.clear)
      @sub_contexts.try(&.clear)
    end

    def reset(name : Symbol)
      clear
      @name = name
    end

    # safe merge, will clone and duplicate
    def merge(from : Context)
      unless (_from_sub_contexts = from.@sub_contexts).nil? || _from_sub_contexts.empty?
        if (_sub_contexts = @sub_contexts).nil?
          @sub_contexts = _from_sub_contexts.clone
        else
          _sub_contexts.merge(_from_sub_contexts)
        end
      end

      unless (_from_nodes = from.@nodes).nil? || _from_nodes.empty?
        if (_nodes = @nodes).nil?
          @nodes = _from_nodes.dup
        else
          _nodes.concat(_from_nodes)
        end
      end

      unless (_from_tokens = from.@tokens).nil? || _from_tokens.empty?
        if (_tokens = @tokens).nil?
          @tokens = _from_tokens.dup
        else
          _tokens.concat(_from_tokens)
        end
      end
    end

    # unsafe add, will NOT clone and duplicate
    def add!(key : Symbol, value : Context)
      (@sub_contexts ||= Hash(Symbol, Context).new)[key] = value
    end

    def add(value : NodeObj)
      (@nodes ||= Array(NodeObj).new) << value
    end

    def add(values : Array(NodeObj))
      (@nodes ||= Array(NodeObj).new).concat(values)
    end

    def add(value : MatchedToken)
      (@tokens ||= Array(MatchedToken).new) << value
    end

    def add(values : Array(MatchedToken))
      (@tokens ||= Array(MatchedToken).new).concat(values)
    end

    def add(
        key : Symbol,
        value : NodeObj | Array(NodeObj) | MatchedToken | Array(MatchedToken))
      sub_context = Context.new(key)
      sub_context.add(value)
      add!(key, sub_context)
    end


    # Querying
    # ---

    def []?(key : Symbol) : Context?
      if key == @name
        self
      else
        _sub_contexts = @sub_contexts
        _sub_contexts.nil? ? nil : _sub_contexts[key]?
      end
    end

    def [](key : Symbol) : Context
      self.[]?(key) || raise Error::Internal.new("Expected subcontext :#{key} for :#{@name} not found. #{self.pretty_inspect}.")
    end

    def node?(index : Int32 = 0) : NodeObj?
      @nodes.try(&.[index]?)
    end

    def node(index : Int32 = 0) : NodeObj
      node?(index) || raise Error::Internal.new("Expected NodeObj for :#{@name} not found. #{self.pretty_inspect}.")
    end

    def nodes? : Array(NodeObj)?
      @nodes.try(&.dup)
    end

    def nodes : Array(NodeObj)
      nodes? || raise Error::Internal.new("Expected nodes for :#{@name} not found. #{self.pretty_inspect}.")
    end

    def token?(index : Int32 = 0) : MatchedToken?
      @tokens.try(&.[index]?)
    end

    def token(index : Int32 = 0) : MatchedToken
      token?(index) || raise Error::Internal.new("Expected token for :#{@name} not found. #{self.pretty_inspect}.")
    end

    def tokens? : Array(MatchedToken)?
      @tokens.try(&.dup)
    end

    def tokens : Array(MatchedToken)
      tokens? || raise Error::Internal.new("Expected tokens for :#{@name} not found. #{self.pretty_inspect}.")
    end

    # Root result
    def result : NodeObj
      _tokens = @tokens
      _nodes = @nodes
      _sub_contexts = @sub_contexts
      unless _tokens.nil? || _tokens.empty?
        raise Error::Internal.new("Root must return no tokens. #{@tokens.pretty_inspect}")
      end
      unless _sub_contexts.nil? || _sub_contexts.empty?
        raise Error::Internal.new("Root must return no subcontexts. #{@sub_contexts.pretty_inspect}")
      end

      if _nodes.nil? || _nodes.size < 1
        raise Error::Internal.new("Root returned no Nodes. #{@nodes.pretty_inspect}")
      end
      if _nodes.size > 1
        raise Error::Internal.new("Root returned more than one Node. #{@nodes.pretty_inspect}")
      end

      return _nodes.first
    end
  end
end
