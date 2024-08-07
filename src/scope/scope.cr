module Magiika
  abstract class Scope
    getter name : String

    def position? : Position?
      @position
    end

    def initialize(@name : String, @position : Position? = nil)
    end

    abstract def get?(ident : String) : Node::Meta?

    def get(ident : String) : Node::Meta
      obj = get?(ident)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(ident, self)
    end

    def get_fn?(
        ident : String,
        args : FnArgs,
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}?
      variable = get?(ident)
      return nil unless variable.is_a?(Node::Fn)

      match_result, param_hash \
        = variable.match_args(args, deep_analysis);

      return deep_analysis ? {match_result, {variable, param_hash}} : nil
    end

    def get_fn(
        ident : String,
        args : FnArgs,
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}
      fn = get_fn?(ident, args, deep_analysis)
      return fn unless fn.nil?
      raise Error::UndefinedVariable.new(ident, self)
    end

    abstract def set(ident : String, meta : Node::Meta) : ::Nil
    def set(ident : String, value : TypeNode) : ::Nil
      set(ident, Node::Meta.new(value).as(Node::Meta))
    end

    abstract def exist?(ident : String) : ::Bool

    abstract def find_global_scope() : Scope::Global
  end
end
