module Magiika::Lang
  module ContextTemplate::Modifying
    def clear
      @nodes.try(&.clear)
      @tokens.try(&.clear)
      @sub_contexts.try(&.clear)
    end

    def reset(name : Symbol)
      clear
      @name = name
    end

    protected def drop_token(index : Int32)
      if !((tokens = @tokens).nil?) && index < tokens.size
        tokens.delete_at(index)
      end
    end

    def drop_tokens
      @tokens.try(&.clear)
    end

    protected def drop_node(index : Int32)
      if !((nodes = @nodes).nil?) && index < nodes.size
        nodes.delete_at(index)
      end
    end

    def drop_nodes
      @nodes.try(&.clear)
    end

    private def drop_context(key : Symbol)
      @sub_contexts.try(&.delete(key))
    end

    def drop_contexts
      @sub_contexts.try(&.clear)
    end

    def drop(key : Symbol, index : Int32 = -1)
      context = self[key]?
      return if context.nil?

      if Util.upcase?(key)
        if index == -1
          context.drop_tokens
        else
          context.drop_token(index)
        end
      else
        if index == -1
          context.drop_nodes
        else
          context.drop_node(index)
        end
      end

      if index == -1
        drop_context(key)
      end
    end

    def flatten
      @sub_contexts.try(&.each { |key, context|
        drop_context(key)
        context.flatten
        unsafe_merge(context)
      })
    end

    def absorb(key : Symbol)
      context = @sub_contexts.try(&.[key]?)
      return if context.nil?

      drop_context(key)
      unsafe_merge(context)
    end

    def become(key : Symbol)
      context = @sub_contexts.try(&.[key]?)
      return if context.nil?

      clear
      unsafe_merge(context)
    end

    def become(data : Psuedo::Node | MatchedToken)
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

    def add(value : Psuedo::Node)
      (@nodes ||= Array(Psuedo::Node).new) << value
    end

    def add(values : Array(Psuedo::Node))
      (@nodes ||= Array(Psuedo::Node).new).concat(values)
    end

    def add(value : MatchedToken)
      (@tokens ||= Array(MatchedToken).new) << value
    end

    def add(values : Array(MatchedToken))
      (@tokens ||= Array(MatchedToken).new).concat(values)
    end

    # unsafe add, will NOT clone and duplicate
    def unsafe_add(
        key : Symbol,
        value : Context)
      sub_contexts = @sub_contexts
      if sub_contexts.nil?
        (@sub_contexts = Hash(Symbol, Context).new)[key] = value
      else
        sub_context = sub_contexts[key]?
        if sub_context.nil?
          sub_contexts[key] = value
        else
          sub_context.unsafe_merge(value)
        end
      end
    end

    def add(
        key : Symbol,
        value : Psuedo::Node | Array(Psuedo::Node) | MatchedToken | Array(MatchedToken))
      sub_contexts = @sub_contexts
      if sub_contexts.nil?
        value_context = Context.new(key)
        value_context.add(value)

        (@sub_contexts = Hash(Symbol, Context).new)[key] \
          = value_context
      else
        sub_context = sub_contexts[key]?
        if sub_context.nil?
          value_context = Context.new(key)
          value_context.add(value)

          sub_contexts[key] = value_context
        else
          sub_context.add(value)
        end
      end
    end
  end
end
