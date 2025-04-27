module Magiika
  abstract class Object::Function < Object
    @defining_scope : Scope?
    getter name : ::String
    getter parameters : Array(Parameter)
    getter returns : AnyObject?

    def initialize(
      @defining_scope : Scope?,
      @name : ::String,
      @parameters : Array(Parameter),
      @returns : AnyObject? = nil,
      position : Position? = nil,
    )
      # Check that the name starts with a lowercase character
      if !(Util.downcase?(@name[0]))
        raise Error::NamingConvention.new(
          "Function and Method names must start with a lowercase character.")
      end

      # Check that there are no param duplicates
      begin
        param_names = Set(::String).new
        @parameters.each do |param|
          name = param.name.lchop("**").lchop("*")  # Remove ** and * prefixes for kwargs/args
          if param_names.includes?(name)
            raise Error::Internal.new("Duplicate parameter name: '#{name}'")
          end
          param_names.add(name)
        end
      end

      super(position)
    end

    def match_args(
      args : Array(Argument),
      deep_analysis : ::Bool = false,
    ) \
       : {MatchResult, Hash(::String, AnyObject)?}
        anon_args = Array(AnyObject).new
        kw_args = Hash(::String, AnyObject).new
        args.each do |arg|
          name = arg.name
          if name.nil?
            anon_args << arg.value
          elsif !(kw_args[name]?.nil?)
            raise Error::Internal.new("duplicate keyword argument: '#{name}'")
          else
            kw_args[name] = arg.value
          end
        end

        arg_to_param_mapping = Hash(::String, AnyObject).new
        match_result = MatchResult.new

        @parameters.each do |param|
          p_name = param.name
          arg_value : AnyObject? = nil

          # figure out what type of parameter this is
          # and handle the argument accordingly
          if p_name.starts_with?("**")
            # FIXME: Implement kwargs, need hash node first
            raise Error::NotImplemented.new("kwargs not implemented")
          elsif p_name.starts_with?("*")
            arg_value = List.new(anon_args)
            anon_args.clear
          else
            arg_value = kw_args.delete(p_name)
            if arg_value.nil?
              arg_value = anon_args.pop?
              if arg_value.nil?
                p_value = param.default_value
                if p_value.nil?
                  match_result.add_error("Missing argument for parameter \"#{p_name}\"")
                  break unless deep_analysis
                  next
                else
                  arg_value = p_value
                end
              end
            end
          end

          # check for duplicate
          unless arg_to_param_mapping[p_name]?.nil?
            match_result.add_error("Duplicate argument for parameter \"#{p_name}\"")
            break unless deep_analysis
            next
          end

          # map
          arg_to_param_mapping[p_name] = arg_value
        end

        # Check if there are unmatched arguments
        unless anon_args.empty?
          match_result.add_error("Unmatched anonymous arguments remaining:\n  #{anon_args}")
        end
        unless kw_args.empty?
          match_result.add_error("Unmatched keyword arguments remaining:\n  #{kw_args}")
        end

        if match_result.matched?
          {match_result, arg_to_param_mapping}
        else
          {match_result, nil}
        end
      end

    # evaluation operation
    protected abstract def method_eval(
      method_scope : Scope,
    ) : AnyObject

    # call operation
    def call(args : Hash(::String, AnyObject)) : AnyObject
      Scope.use(
        name: @name,
        parent: @defining_scope,  # may be nil
        position: position
      ) do |method_scope|
        # inject args into scope
        args.each { |key, value|
          method_scope.define(key, value)
        }

        # perform operation
        result = method_eval(method_scope)
        # validate result
        @returns.try { |t| result.is_of!(t) }
        return result
      end
    end

    def call_safe(
      args : Array(Argument),
      arg_scope : Scope,  # FIXME this doesn't actually do anything
      deep_analysis : ::Bool = false,
    ) : MatchResult | AnyObject
      match_result, args_hash = match_args(args, deep_analysis)

      return match_result unless match_result.matched?
      raise Error::Internal.new("Unexpected nil.") if args_hash.nil?

      call(args_hash)
    end

    def call_safe_raise(
      args : Array(Argument),
      arg_scope : Scope,
      deep_analysis : ::Bool = false,
    ) : AnyObject
      result = call_safe(args, arg_scope, deep_analysis)

      result.as(MatchResult).raise if result.is_a?(MatchResult)
      return result.as(AnyObject)
    end

    def pretty_sig
      "#{@name}(" +
      (@parameters.map { |param|
        param_value = param.default_value
        ("\n  :" + param.name.to_s + 
         (param_value.nil? ? "" : " = #{param_value.to_s_internal}"))
      }).join(separator = ",") +
      ")" +
      (@returns.nil? ? "" : "-> #{@returns}")
    end

    def to_s_internal : ::String
      "fn #{pretty_sig}"
    end
  end
end
