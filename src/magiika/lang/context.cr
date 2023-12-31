require "./token.cr"


module Magiika::Lang
  class RuleContext
    getter rule_name : Symbol
    getter node_results : Hash(Symbol, Array(Node))
    getter token_results : Hash(Symbol, Array(MatchedToken))

    def initialize(@rule_name : Symbol, @node_results = Hash(Symbol, Array(Node)).new, @token_results = Hash(Symbol, Array(MatchedToken)).new)
    end

    def node?(name : Symbol, index : Int32 = 0) : Node?
      @node_results[name]?.try(&.[index]?)
    end

    def node(name : Symbol, index : Int32 = 0) : Node
      node?(name, index) || raise Error::Internal.new("Expected node not found: :#{name}. Has: #{@node_results}. Rule name: :#{@rule_name}.")
    end

    def nodes?(name : Symbol) : Array(Node)?
      @node_results[name]?
    end

    def nodes(name : Symbol) : Array(Node)
      @node_results[name]? || raise Error::Internal.new("Expected nodes not found: :#{name}")
    end

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
      @token_results[name]? || raise Error::Internal.new("Expected tokens not found: #{name}")
    end

    def result : Node
      unless @token_results.empty?
        raise Error::Internal.new("Root must return no tokens. #{@token_results.pretty_inspect}")
      end
      if @node_results.size < 1
        raise Error::Internal.new("Root did not return a Node.")
      end
      if @node_results.size > 1 || (arr = @node_results.first_value).size > 1
        raise Error::Internal.new("Root returned more than one Node. #{@node_results.pretty_inspect}")
      end

      return @node_results.first_value.first
    end

    def update(results : Hash(Symbol, Node | MatchedToken | Array(Node) | Array(MatchedToken)))
      results.each do |key, value|
        case value
        when Node
          (@node_results[key] ||= [] of Node) << value
        when Array(Node)
          (@node_results[key] ||= [] of Node).concat(value)
        when MatchedToken
          (@token_results[key] ||= [] of MatchedToken) << value
        when Array(MatchedToken)
          (@token_results[key] ||= [] of MatchedToken).concat(value)
        end
      end
    end

    def update(name : Symbol, value : Node)
      (@node_results[name] ||= [] of Node) << value
    end

    def update(name : Symbol, value : MatchedToken)
      (@token_results[name] ||= [] of MatchedToken) << value
    end

    def update(context : RuleContext)
      update(context.node_results)
      update(context.token_results)
    end

    def update(name : Symbol, context : RuleContext)
      unless context.node_results.empty?
        @node_results[name] ||= [] of Node
        context.node_results.each do |key, nodes|
          @node_results[name].concat(nodes)
        end
      end
      
      unless context.token_results.empty?
        @token_results[name] ||= [] of MatchedToken
        context.token_results.each do |key, tokens|
          @token_results[name].concat(tokens)
        end
      end
    end
  end
end
