module Magiika
  abstract class Scope
    property name : String

    getter? position : Position?
    def position : Position
      position? || Position.new
    end

    def initialize(@name : String, @position : Position? = nil)
    end

    abstract def cleanup : ::Nil

    protected def reference_type(value : TypeNode) : ::Nil
      if value.is_a?(InstTypeNode)
        value.reference_type(scope: self)
      end
    end

    protected def unreference_type(value : TypeNode) : ::Nil
      value.unreference_type() if value.is_a?(InstTypeNode)
    end

    def self.use(
        *args,
        **kwargs,
        & : self -> R) : R forall R
      instance = new(*args, **kwargs)
      begin
        yield instance
      ensure
        instance.cleanup
      end
    end


    # ✨ Setting values
    # ---

    # define a new value
    abstract def define(name : String, meta : Node::Meta) : ::Nil

    def define(name : String, value : TypeNode) : ::Nil
      define(name, Node::Meta.new(value))
    end

    def define(pairs : Hash(String, TypeNode | Node::Meta)) ::Nil
      pairs.each{ |name, value| define(name, value) }
    end

    # replace an existing value
    abstract def replace(name : String, meta : Node::Meta) : ::Nil

    def replace(name : String, value : TypeNode) : ::Nil
      replace(name, Node::Meta.new(value))
    end

    def replace(pairs : Hash(String, TypeNode | Node::Meta)) ::Nil
      pairs.each{ |name, value| replace(name, value) }
    end

    # assign (define or replace) a value
    abstract def assign(name : String, meta : Node::Meta) : ::Nil

    def assign(name : String, value : TypeNode) : ::Nil
      assign(name, Node::Meta.new(value))
    end

    def assign(pairs : Hash(String, TypeNode | Node::Meta)) ::Nil
      pairs.each{ |name, value| assign(name, value) }
    end


    # ✨ Retrieving values
    # ---

    abstract def retrieve?(name : String) : Node::Meta?

    def retrieve(name : String) : Node::Meta
      obj = retrieve?(name)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(name, self)
    end

    def retrieve_fn?(
        name : String,
        args : FnArgs,
        deep_analysis : ::Bool = false) \
          : {MatchResult, {Node::Fn, Hash(String, Node)}?}?
      variable = retrieve?(name)
      return nil unless variable.is_a?(Node::Fn)

      match_result, param_hash \
        = variable.match_args(args, deep_analysis);

      return deep_analysis ? {match_result, {variable, param_hash}} : ::Nil
    end

    def retrieve_fn(
        name : String,
        args : FnArgs,
        deep_analysis : ::Bool = false) \
          : {MatchResult, {Node::Fn, Hash(String, Node)}?}
      fn = retrieve_fn?(name, args, deep_analysis)
      return fn unless fn.nil?
      raise Error::UndefinedVariable.new(name, self)
    end


    # ✨ Iterate or locate
    # ---

    abstract def exist?(name : String) : ::Bool
    abstract def exist_here?(name : String) : ::Bool

    def seek(&block : Scope -> R) : R? forall R
      block.call(self)
    end

    abstract def find_base_scope : Scope
  end
end
