module Magiika
  abstract class FunctionInstance < Instance
    getter name : ::String
    getter parameters : Array(Parameter)
    getter returns : Object?

    def initialize(
      type_instance : Function,
      @name : ::String,
      @parameters : Array(Parameter),
      @returns : Object? = nil,
      position : Position? = nil
    )
      super(type_instance, position)

      Checks.function_name(@name)
      Checks.parameters(@parameters)
    end

    def match_args(
      args : Array(Argument),
      deep_analysis : ::Bool = false,
    ) : {MatchResult, Hash(::String, Object)?}
      anon_args = Array(Object).new
      kw_args = Hash(::String, Object).new
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

      arg_to_param_mapping = Hash(::String, Object).new
      match_result = MatchResult.new

      @parameters.each do |param|
        p_name = param.name
        arg_value : Object? = nil

        # figure out what type of parameter this is
        # and handle the argument accordingly
        if p_name.starts_with?("**")
          # FIXME: Implement kwargs, need hash node first
          raise Error::NotImplemented.new("kwargs not implemented")
        elsif p_name.starts_with?("*")
          arg_value = list_t.create_instance(anon_args)
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
    ) : Object

    # call operation
    def call(args : Hash(::String, Object)) : Object
      @function_defining_scope.root_scope.check_resource_limits!

      Scope.use(
        name: @name,
        parent: @function_defining_scope,
        position: position) do |method_scope|
        # inject args into scope
        args.each { |key, value|
          method_scope.define(key, value)
        }

        # perform operation
        begin
          result = method_eval(method_scope)
        rescue BreakSignal
          raise Error::Lazy.new("'break' used outside of a loop.")
        rescue NextSignal
          raise Error::Lazy.new("'next' used outside of a loop.")
        end
        # validate result
        @returns.try { |t| result.is_of!(t) }
        return result
      end
    end

    def call_safe(
      args : Array(Argument),
      arg_scope : Scope, # FIXME this doesn't actually do anything
      deep_analysis : ::Bool = false,
    ) : MatchResult | Object
      match_result, args_hash = match_args(args, deep_analysis)

      return match_result unless match_result.matched?
      raise Error::Internal.new("Unexpected nil.") if args_hash.nil?

      call(args_hash)
    end

    def call_safe_raise(
      args : Array(Argument),
      arg_scope : Scope,
      deep_analysis : ::Bool = false,
    ) : Object
      result = call_safe(args, arg_scope, deep_analysis)

      result.as(MatchResult).raise if result.is_a?(MatchResult)
      return result.as(Object)
    end

    def object_name : ::String
      "#{@name}()"
    end

    @[AlwaysInline]
    def to_s : ::String
      "<#{self.object_name}>"
    end

    @[AlwaysInline]
    def inspect : ::String
      String.build do |sb|
        sb << "<#{@name}("
        @parameters.each { |p|
          sb << "\n  :"
          sb << p.name
          sb << " = #{p.default_value}") unless p.default_value.nil?
          sb << ','
        }
        sb << ')'
        sb << "-> #{@returns}" unless @returns.nil?
        sb << '>'
      end
    end
  end

  class Function < GenericType(FunctionInstance)
  end
end
