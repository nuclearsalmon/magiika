module Magiika::Lang
  module ContextTemplate::Modifying
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

    protected def drop_tokens(index : Int32 = -1)
      if index == -1
        clear_tokens
      else
        if !((tokens = @tokens).nil?) && index < tokens.size
          tokens.delete_at(index)
        end
      end
    end

    protected def drop_nodes(index : Int32 = -1)
      if index == -1
        clear_nodes
      else
        if !((nodes = @nodes).nil?) && index < nodes.size
          nodes.delete_at(index)
        end
      end
    end

    private def drop_context(key : Symbol)
      @sub_contexts.try(&.delete(key))
    end

    def drop(key : Symbol, index : Int32 = -1)
      context = self[key]?
      return if context.nil?

      if ObjectExtensions.upcase?(key)
        context.drop_tokens(index)
      else
        context.drop_nodes(index)
      end

      if index == -1 && context.empty?
        drop_context(key)
      end
    end

    def flatten
      @sub_contexts.try(&.each { |key, context|
        drop_context(key)
        unsafe_merge(context)
      })
    end

    def absorb(key : Symbol)
      context = self[key]
      drop_context(key)
      unsafe_merge(context)
    end

    def become(key : Symbol)
      context = self[key]
      clear
      unsafe_merge(context)
    end

    def become(data : NodeObj | MatchedToken)
      clear
      add(data)
    end

    private def internal_merge(from : Context, safe : ::Bool)
      unless (from_sub_contexts = from.@sub_contexts).nil? || from_sub_contexts.empty?
        if safe
          from_sub_contexts = from_sub_contexts.clone
        end

        if (sub_contexts = @sub_contexts).nil?
          @sub_contexts = from_sub_contexts
        else
          sub_contexts.merge(from_sub_contexts)
        end
      end

      unless (from_nodes = from.@nodes).nil? || from_nodes.empty?
        if (nodes = @nodes).nil?
          @nodes = safe ? from_nodes.dup : from_nodes
        else
          nodes.concat(from_nodes)
        end
      end

      unless (from_tokens = from.@tokens).nil? || from_tokens.empty?
        if (tokens = @tokens).nil?
          @tokens = safe ? from_tokens.dup : from_tokens
        else
          tokens.concat(from_tokens)
        end
      end
    end

    # safe merge, will clone and duplicate
    def merge(from : Context)
      internal_merge(from, true)
    end

    # unsafe merge, will NOT clone and duplicate
    def unsafe_merge(from : Context)
      internal_merge(from, false)
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

    # unsafe add, will NOT clone and duplicate
    def unsafe_add(key : Symbol, value : Context)
      (@sub_contexts ||= Hash(Symbol, Context).new)[key] = value
    end

    def add(
        key : Symbol,
        value : NodeObj | Array(NodeObj) | MatchedToken | Array(MatchedToken))
      sub_context = Context.new(key)
      sub_context.add(value)
      unsafe_add(key, sub_context)
    end
  end
end
