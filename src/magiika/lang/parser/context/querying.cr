module Magiika::Lang
  module ContextTemplate::Querying
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

    def empty? : ::Bool
      return false unless (tokens = @tokens).nil? || tokens.empty?
      return false unless (nodes = @nodes).nil? || nodes.empty?
      return false unless (sub_contexts = @sub_contexts).nil? || sub_contexts.empty?
      return true
    end

    # Root result
    def result : NodeObj
      _tokens = @tokens
      _nodes = @nodes
      _sub_contexts = @sub_contexts
      unless _tokens.nil? || _tokens.empty?
        raise Error::Internal.new("Root must return no tokens. #{pretty_inspect}")
      end
      unless _sub_contexts.nil? || _sub_contexts.empty?
        raise Error::Internal.new("Root must return no subcontexts. #{pretty_inspect}")
      end

      if _nodes.nil? || _nodes.size < 1
        raise Error::Internal.new("Root returned no Nodes. #{pretty_inspect}")
      end
      if _nodes.size > 1
        raise Error::Internal.new("Root returned more than one Node. #{pretty_inspect}")
      end

      return _nodes.first
    end

    def position : Lang::Position
      lowest_position = nil

      @tokens.try(&.each { |token|
        token_position = token.position
        if (lowest_position.nil? ||
            (token_position.row <= lowest_position.row &&
            token_position.col < lowest_position.col))
          lowest_position = token_position
        end
      })

      @nodes.try(&.each { |node|
        node_position = node.position
        if (lowest_position.nil? ||
            (node_position.row <= lowest_position.row &&
            node_position.col < lowest_position.col))
          lowest_position = node_position
        end
      })

      @sub_contexts.try(&.each { |sub_context|
        sub_context_position = sub_context.position
        if (lowest_position.nil? ||
            (sub_context_position.row <= lowest_position.row &&
            sub_context_position.col < lowest_position.col))
          lowest_position = sub_context_position
        end
      })

      if lowest_position.nil?
        if empty?
          raise Error::Internal.new("Could not find a context position, because it is empty.")
        else
          raise Error::Internal.new("Could not find a context position, yet context is not empty.")
        end
      end
    end
  end
end
