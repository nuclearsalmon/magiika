module Magiika
  struct Node::FnParam < NodeStructBase
    getter name : String
    getter constraint : Node::Constraint
    getter value : Node?

    def initialize(
        position : Lang::Position,
        @name : String, 
        @constraint : Node::Constraint = Node::Constraint.new(),
        @value : Node? = nil)
      super(position)
    end
  end

  #record FnParam,
  #  name : String,
  #  constraint : Node::Constraint,
  #  value : Node? = nil
  
  alias Node::FnParams = Array(Node::FnParam)

  record FnArg,
    name : String?,
    value : Node

  alias FnArgs = Array(FnArg)
  
  abstract class Node::Function < NodeClassBase
    getter name : String
    getter params : FnParams
    getter returns : Array(Constraint)

    def initialize(
        position : Lang::Position,
        @name : String,
        @params : FnParams,
        @returns : Array(Constraint))
      super(position)
    end

    def eval(scope : Scope) : Node
      self
    end

    def match_args(args : FnArgs, deep_analysis : ::Bool = false) \
        : {MatchResult, Hash(String, Node)?}
      regular_args = args.dup
      var_args = [] of Node
      keyword_args = {} of String => Node
      match_result = MatchResult.new(true)
      arg_to_param_mapping = {} of String => Node

      @params.each do |param|
        if param.name.starts_with?("*")
          var_args = regular_args.dup
          regular_args.clear
          var_args_node = List.new(var_args.map(&.value), Lang::Position.new) # Wrap var_args in ListNode
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
        
          constraint_result = param.constraint.validate(arg.value)
          unless constraint_result.matched?
            match_result.merge!(constraint_result)
            break unless deep_analysis
          end
          arg_to_param_mapping[param.name] = arg.value
        end
      end
    
      # Handle keyword arguments (keyword_args)
      keyword_args.each do |name, arg|
        kwarg_param = @params.find { |p| p.name == name }
        if kwarg_param
          constraint_result = kwarg_param.constraint.validate(arg)
          unless constraint_result.matched?
            match_result.merge!(constraint_result)
            break unless deep_analysis
          end
        else
          match_result.add_error("No constraint found for keyword argument '#{name}'")
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

    abstract def call(args : Hash(String, Node), scope : Scope) : Node

    def call_safe(
        args : FnArgs, 
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | Node
      match_result, args_hash = match_args(args, deep_analysis)
      return match_result unless match_result.matched?

      # handle compiler error
      raise Error::Internal.new("Unexpected nil.") if args_hash.nil?
      call(args_hash, scope)
    end

    def call_safe_raise(
        args : FnArgs, 
        scope : Scope,
        deep_analysis : ::Bool = false) : Node
      result = call_safe(args, scope, deep_analysis)

      result.as(MatchResult).raise if result.is_a?(MatchResult)
      return result.as(Node)
    end

    def pretty_sig
      "#{@name}(\n  " + \
        (@params.map { |p| 
          (p.constraint._type.nil? ? ':' : "#{p.constraint._type}: ") + \
            p.name.to_s + \
            (p.constraint._type == Node::Nil.class ? "" : p.constraint._type.to_s)
        }).join(separator=",\n  ") + \
        ")" + \
        (@returns == Node::Nil.class ? "" : "-> #{@returns}")
    end

    def to_s
      "fn #{pretty_sig}"
    end
  end

  class Node::AbstractFn < Node::Function
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : Array(Constraint))
      super(position, name, params, returns)
    end

    def call(args : Hash(String, Node), scope : Scope) : Node
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def call_safe(
        args : FnArgs, 
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | Node
      raise Error::Internal.new("Abst fn is not callable.")
    end
    
    def to_s
      "abst fn #{pretty_sig}"
    end
  end

  class Node::NativeFn < Node::Function
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : Array(Constraint),
        @proc : Proc(Scope, Node))
      super(position, name, params, returns)
    end

    def initialize(
        name : String,
        params : FnParams,
        returns : Array(Constraint),
        @proc : Proc(Scope, Node))
      super(Lang::Position.new, name, params, returns)
    end

    def call(args : Hash(String, Node), scope : Scope) : Node
      # Inject args into scope
      method_scope = Scope::MethodScope.new(@name, @position, scope)
      args.each do |name, value|
        method_scope.set(name, value)
      end

      result = @proc.call(method_scope)

      # typecheck
      @returns.each do |constraint|
        validation_result = constraint.validate(result)
        unless validation_result.matched?
          validation_result.raise
        end
      end
      return result
    end

    def to_s
      "native fn #{pretty_sig}"
    end
  end

  class Node::StatementFn < Node::Function
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : Constraint,
        @statements : Array(Node))
      super(position, name, params, returns)
    end
    
    def call(args : Hash(String, Node), scope : Scope) : Node
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

    def to_s
      "fn #{pretty_sig}"
    end
  end
end
