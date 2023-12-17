module Magiika
  abstract class Scope
    getter name : String
    getter position : Lang::Position

    def initialize(
        @name : String,
        @position : Lang::Position)
    end

    abstract def get?(ident : String) : Node::Meta?
    
    def get?(ident : Lang::MatchedToken) : Node::Meta?
      get?(ident.value)
    end

    def get(ident : String) : Node::Meta
      obj = get?(ident)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(ident, self, Lang::Position.new)
    end
    
    def get(ident : Lang::MatchedToken) : Node::Meta
      obj = get?(ident.value)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(ident.value, self, ident.pos)
    end

    def get_fn?(
        ident : String,
        args : FnArgs, 
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}?
      variable = get?(ident)
      return nil unless variable.is_a?(Node::Function)

      match_result, param_hash \
        = variable.match_args(args, deep_analysis);
      
      return match_result.error? ? nil : {match_result, {variable, param_hash}}
    end

    def get_fn?(
        ident : Lang::MatchedToken, 
        args : FnArgs, 
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}?
      get_fn?(ident.value, args, deep_analysis)
    end

    def get_fn(
        ident : String,
        args : FnArgs, 
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}
      function = get_fn?(ident, args, deep_analysis)
      return function if function
      raise Error::UndefinedVariable.new(ident, self, Position.new)
    end

    def get_fn(
        ident : Lang::MatchedToken,
        args : FnArgs, 
        deep_analysis : Bool = false) \
          : {MatchResult, {Function, Hash(String, Node)}?}
      function = get_fn?(ident, args, deep_analysis)
      return function if function
      raise Error::UndefinedVariable.new(ident.value, self, ident.position)
    end

    abstract def set(ident : String, value : Node) : Nil
    def set(ident : Lang::MatchedToken, value : Node) : Nil
      set(ident.value, value)
    end

    abstract def exist?(ident : String) : ::Bool
    def exist?(ident : Lang::MatchedToken) : ::Bool
      exist?(ident.value)
    end

    abstract def exist_here?(ident : String) : ::Bool
    def exist_here?(ident : Lang::MatchedToken) : ::Bool
      exist_here?(ident.value)
    end

    abstract def find_global_scope() : self
  end
end
