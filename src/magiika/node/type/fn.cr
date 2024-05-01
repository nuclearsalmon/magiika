require "../../util/match_result.cr"

module Magiika
  class Node::FnParam < NodeClassBase
    getter name : String
    getter _type : NodeAny?
    getter descriptors : Set(Node::Desc)?
    getter value : NodeObj?

    def initialize(
        @name : String,
        @_type : NodeAny? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @value : NodeObj? = nil,
        position : Lang::Position? = nil)
      super(position)
    end

    def initialize(
        @name : String,
        @_type : NodeAny? = nil,
        descriptor : Node::Desc? = nil,
        @value : NodeObj? = nil,
        position : Lang::Position? = nil)
      unless descriptor.nil?
        descriptors = Set(Node::Desc).new
        descriptors << descriptor
        @descriptors = descriptors
      end
      super(position)
    end

    def validate(node : NodeObj) : MatchResult
      descriptors = @descriptors
      unless descriptors.nil?
        descriptors.each { |descriptor|
          result = descriptor.validate(node)
          return result unless result.matched?
        }
      end
      return MatchResult.new(true)
    end
  end

  alias Node::FnParams = Array(Node::FnParam)

  record FnArg,
    name : String?,
    value : NodeObj

  alias FnArgs = Array(FnArg)

  record FnRet,
    _type : NodeType? = nil,
    descs : Set(Node::Desc)? = nil

  abstract class Node::Function < NodeClassBase
    getter name : String
    getter params : FnParams
    getter returns : FnRet?

    def initialize(
        @name : String,
        @params : FnParams,
        @returns : FnRet? = nil)
      super(nil)
    end

    def initialize(
        position : Lang::Position,
        @name : String,
        @params : FnParams,
        @returns : FnRet? = nil)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      self
    end

    def match_args(args : FnArgs, deep_analysis : ::Bool = false) \
        : {MatchResult, Hash(String, NodeObj)?}
      regular_args = args.dup
      var_args = [] of NodeObj
      keyword_args = {} of String => NodeObj
      match_result = MatchResult.new(true)
      arg_to_param_mapping = {} of String => NodeObj

      @params.each do |param|
        if param.name.starts_with?("*")
          var_args = regular_args.dup
          regular_args.clear
          var_args_node = List.new(var_args.map(&.value)) # Wrap var_args in ListNode
          arg_to_param_mapping[param.name.lstrip('*')] = var_args_node
        elsif param.name.starts_with?("**")
          # Skip handling here, will process after regular args
        else
          arg = regular_args.pop
          unless arg
            match_result.add_error("Missing argument for parameter '#{param.name}'")
            break unless deep_analysis
            next
          end

          descriptor_result = param.validate(arg.value)
          unless descriptor_result.matched?
            match_result.merge!(descriptor_result)
            break unless deep_analysis
          end
          arg_to_param_mapping[param.name] = arg.value
        end
      end

      # Handle keyword arguments (keyword_args)
      keyword_args.each do |name, arg|
        kwarg_param = @params.find { |p| p.name == name }
        if kwarg_param
          descriptor_result = kwarg_param.validate(arg)
          unless descriptor_result.matched?
            match_result.merge!(descriptor_result)
            break unless deep_analysis
          end
        else
          match_result.add_error("No descriptor found for keyword argument '#{name}'")
        end
        arg_to_param_mapping[name] = arg
      end

      # Check if there are unmatched regular arguments
      if !regular_args.empty?
        match_result.add_error("Unmatched regular arguments remaining")
      end

      if match_result.matched?
        {match_result, arg_to_param_mapping}
      else
        {match_result, nil}
      end
    end

    abstract def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj

    def call_safe(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | NodeObj
      match_result, args_hash = match_args(args, deep_analysis)
      return match_result unless match_result.matched?

      # handle compiler error
      raise Error::Internal.new("Unexpected nil.") if args_hash.nil?
      call(args_hash, scope)
    end

    def call_safe_raise(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : NodeObj
      result = call_safe(args, scope, deep_analysis)

      result.as(MatchResult).raise if result.is_a?(MatchResult)
      return result.as(NodeObj)
    end

    def pretty_sig
      "#{@name}(\n  " + \
        (@params.map { |p|
          cs_map_str = ":"
          descriptors = p.descriptors
          unless descriptors.nil?
            cs_map_str = descriptors.map { |descriptor|
              "#{descriptor.class.pretty_inspect}"
            }.join(separator='\n')
          end

          cs_map_str + " " + p.name.to_s
        }).join(separator=",\n  ") + \
        ")" + \
        (@returns == Node::Nil.class ? "" : "-> #{@returns}")
    end

    def to_s_internal : String
      "fn #{pretty_sig}"
    end
  end

  class Node::AbstractFn < Node::Function
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : FnRet? = nil)
      super(position, name, params, returns)
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def call_safe(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | NodeObj
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def to_s_internal : String
      "abst fn #{pretty_sig}"
    end
  end

  class Node::NativeFn < Node::Function
    def initialize(
        name : String,
        params : FnParams,
        @proc : Proc(Scope, NodeObj),
        returns : FnRet? = nil)
      super(name, params, returns)
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      # Inject args into scope
      method_scope = Scope::MethodScope.new(@name, position, scope)
      args.each do |name, value|
        method_scope.set(name, value)
      end

      result = @proc.call(method_scope)

      # validat result
      returns = @returns
      unless returns.nil?
        # type check
        _type = returns._type
        if !_type.nil? && !result.type?(_type)
          raise Error::Internal.new("Unexpected type")
        end

        # descriptor check
        descs = returns.descs
        unless descs.nil?
          descs.each do |descriptor|
            validation_result = descriptor.validate(result)
            unless validation_result.matched?
              validation_result.raise
            end
          end
        end
      end

      return result
    end

    def to_s_internal : String
      "native fn #{pretty_sig}"
    end
  end

  class Node::StatementFn < Node::Function
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : Node::Desc,
        @statements : Array(NodeObj))
      super(position, name, params, returns)
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      # TODO inject args into scope

      result = @statements.each { |stmt|
        next stmt.eval(scope)
      }

      # TODO typecheck
      # TODO metawrap

      # handle compiler error
      raise Error::Internal.new("Unexpected nil.") if result.nil?
      return result
    end
  end
end
