require "./modifying"
require "./querying"


module Magiika::Lang
  class Context
    include ContextTemplate::Modifying
    include ContextTemplate::Querying

    property name : Symbol
    @nodes : Array(Psuedo::Node)?
    @tokens : Array(MatchedToken)?
    @sub_contexts : Hash(Symbol, Context)?

    def initialize(
        @name : Symbol,
        @nodes : Array(Psuedo::Node)? = nil,
        @tokens : Array(MatchedToken)? = nil,
        @sub_contexts : Hash(Symbol, Context)? = nil)
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
  end
end
