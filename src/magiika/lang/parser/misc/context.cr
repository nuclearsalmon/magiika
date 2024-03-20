require "./token.cr"


module Magiika::Lang
  private abstract class InterpreterContextBase
    protected getter rule_name : Symbol
    protected getter node_results : Hash(Symbol, Array(Node))
    protected getter token_results : Hash(Symbol, Array(MatchedToken))
    protected getter sub_contexts : Hash(Symbol, Array(InterpreterContext))

    def initialize(
        @rule_name : Symbol, 
        @node_results = Hash(Symbol, Array(Node)).new, 
        @token_results = Hash(Symbol, Array(MatchedToken)).new,
        @sub_contexts = Hash(Symbol, Array(InterpreterContext)).new)
    end

    def initialize(base : InterpreterContextBase)
      @rule_name = base.rule_name
      @node_results = base.node_results
      @token_results = base.token_results
      @sub_contexts = base.sub_contexts
    end


    # Metadata
    # ---

    def name : Symbol
      @rule_name
    end


    # Nodes
    # ---

    def node?(name : Symbol, index : Int32 = 0) : Node?
      @node_results[name]?.try(&.[index]?)
    end

    def node(name : Symbol, index : Int32 = 0) : Node
      node?(name, index) || raise Error::Internal.new("Expected node not found: :#{name}. Has: #{self.pretty_inspect}. Rule name: :#{@rule_name}.")
    end

    def nodes?(name : Symbol) : Array(Node)?
      @node_results[name]?
    end

    def nodes(name : Symbol) : Array(Node)
      nodes?(name) || raise Error::Internal.new("Expected nodes not found: :#{name}")
    end


    # Tokens
    # ---

    def token?(name : Symbol, index : Int32 = 0) : MatchedToken?
      @token_results[name]?.try(&.[index]?)
    end

    def token(name : Symbol, index : Int32 = 0) : MatchedToken
      token?(name, index) || raise Error::Internal.new("Expected token not found: #{name}")
    end

    def tokens?(name : Symbol) : Array(MatchedToken)?
      @token_results[name]?
    end

    def tokens(name : Symbol) : Array(MatchedToken)
      tokens?(name) || raise Error::Internal.new("Expected tokens not found: #{name}")
    end


    # Subcontexts
    # ---

    def context?(name : Symbol, index : Int32 = 0) : InterpreterContext?
      @sub_contexts[name]?.try(&.[index]?)
    end

    def context(name : Symbol, index : Int32 = 0) : InterpreterContext
      context?(name, index) || raise Error::Internal.new("Expected context not found: #{name}")
    end

    def contexts?(name : Symbol) : Array(InterpreterContext)?
      @sub_contexts[name]?
    end

    def contexts(name : Symbol) : Array(InterpreterContext)
      contexts?(name) || raise Error::Internal.new("Expected contexts not found: #{name}")
    end


    # Root result
    # ---

    def result : Node
      unless @token_results.empty?
        raise Error::Internal.new("Root must return no tokens. #{@token_results.pretty_inspect}")
      end
      unless @sub_contexts.empty?
        raise Error::Internal.new("Root must return no subcontexts. #{@sub_contexts.pretty_inspect}")
      end

      if @node_results.size < 1
        raise Error::Internal.new("Root did not return a Node.")
      end
      if @node_results.size > 1 || (arr = @node_results.first_value).size > 1
        raise Error::Internal.new("Root returned more than one Node. #{@node_results.pretty_inspect}")
      end

      return @node_results.first_value.first
    end
  end

  class InterpreterContext < InterpreterContextBase
    def mutable : MutableInterpreterContext
      MutableInterpreterContext.new(self)
    end
  end

  class MutableInterpreterContext < InterpreterContextBase
    def immutable : InterpreterContext
      InterpreterContext.new(self)
    end

    def clear
      @node_results.clear
      @token_results.clear
      @sub_contexts.clear
    end

    def rename(name : Symbol)
      @rule_name = name
    end

    def reset(name : Symbol)
      clear
      rename(name)
    end

    # flatten tokens and nodes from new context into self if there are no subcontexts in new context, else update self by context
    def careful_merge(sym : Symbol, context : InterpreterContext | MutableInterpreterContext, finalize : Bool)
      if context.sub_contexts.empty?
        if finalize && !((node_value = context.node_results[:_]?).nil?)
          (@node_results[sym] ||= [] of Node).concat(node_value)
        elsif !context.node_results.empty?
          @node_results.merge!(context.node_results) 
        end

        if finalize && !((token_value = context.token_results[:_]?).nil?)
          (@token_results[sym] ||= [] of MatchedToken).concat(token_value)
        elsif !context.token_results.empty?
          @token_results.merge!(context.token_results)
        end
      else
        update(sym, context)
      end
    end

    def merge_context(context : InterpreterContext | MutableInterpreterContext)
      @node_results.merge!(context.node_results) unless context.node_results.empty?
      @token_results.merge!(context.token_results) unless context.token_results.empty?
      @sub_contexts.merge!(context.sub_contexts) unless context.sub_contexts.empty?
    end

    def update(name : Symbol, value : Node)
      (@node_results[name] ||= [] of Node) << value
    end
    def update(name : Symbol, value : Array(Node))
      (@node_results[name] ||= [] of Node).concat(value)
    end
    def update(value : Node)
      (@node_results[@rule_name] ||= [] of Node) << value
    end
    def update(value : Array(Node))
      (@node_results[@rule_name] ||= [] of Node).concat(value)
    end

    def update(name : Symbol, value : MatchedToken)
      (@token_results[name] ||= [] of MatchedToken) << value
    end
    def update(name : Symbol, value : Array(MatchedToken))
      (@token_results[name] ||= [] of MatchedToken).concat(value)
    end
    def update(value : MatchedToken)
      (@token_results[@rule_name] ||= [] of MatchedToken) << value
    end
    def update(value : Array(MatchedToken))
      (@token_results[@rule_name] ||= [] of MatchedToken).concat(value)
    end

    def update(name : Symbol, value : InterpreterContext)
      (@sub_contexts[name] ||= [] of InterpreterContext) << value
    end
    def update(name : Symbol, value : Array(InterpreterContext))
      (@sub_contexts[name] ||= [] of InterpreterContext).concat(value)
    end
    def update(value : InterpreterContext)
      (@sub_contexts[@rule_name] ||= [] of InterpreterContext) << value
    end
    def update(value : Array(InterpreterContext))
      (@sub_contexts[@rule_name] ||= [] of InterpreterContext).concat(value)
    end
  end
end
