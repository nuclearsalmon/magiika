module Magiika
  abstract class Node::Fn < NodeClassBase
    getter name : String
    getter params : FnParams
    getter returns : FnRet?

    def initialize(
        @name : String,
        @params : FnParams,
        @returns : FnRet? = nil)
      # FIXME: check that there are no param duplicates
      super(nil)
    end

    def initialize(
        position : Lang::Position,
        @name : String,
        @params : FnParams,
        @returns : FnRet? = nil)
      # FIXME: check that there are no param duplicates
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      self
    end

    def match_args(args : FnArgs, deep_analysis : ::Bool = false) \
        : {MatchResult, Hash(String, NodeObj)?}
      anon_args = Array(NodeObj).new
      kw_args = Hash(String, NodeObj).new
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

      arg_to_param_mapping = Hash(String, NodeObj).new
      match_result = MatchResult.new(true)


      @params.each do |param|
        p_name = param.name
        arg_data : NodeObj? = nil

        # figure out what type of parameter this is
        # and handle the argument accordingly
        if p_name.starts_with?("**")
          raise Error::NotImplemented.new("kwargs not implemented")
        elsif p_name.starts_with?("*")
          arg_data = List.new(anon_args)
          anon_args.clear
        else
          arg_data = kw_args.delete(p_name)
          if arg_data.nil?
            arg_data = anon_args.pop?
            if arg_data.nil?
              match_result.add_error("Missing argument for parameter '#{p_name}'")
              break unless deep_analysis
              next
            end
          end
        end

        # validate by descriptor
        descriptor_result = param.validate(arg_data)
        unless descriptor_result.matched?
          match_result.merge!(descriptor_result)
          break unless deep_analysis
          next
        end

        # check for duplicate
        unless arg_to_param_mapping[p_name]?.nil?
          match_result.add_error("Duplicate argument for parameter '#{p_name}'")
          break unless deep_analysis
          next
        end

        # map
        arg_to_param_mapping[p_name] = arg_data
      end

      # Check if there are unmatched arguments
      unless anon_args.empty?
        match_result.add_error("Unmatched anonymous arguments remaining: #{anon_args}")
      end
      unless kw_args.empty?
        match_result.add_error("Unmatched keyword arguments remaining: #{kw_args}")
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
      "#{@name}(" + \
        (@params.map { |p|
          cs_map_str = "\n  :"
          descriptors = p.descriptors
          unless descriptors.nil?
            cs_map_str = descriptors.map { |descriptor|
              "#{descriptor.class.pretty_inspect}"
            }.join(separator='\n')
          end

          cs_map_str + " " + p.name.to_s
        }).join(separator=",\n  ") + \
        ")" + \
        (@returns.nil? ? "" : "-> #{@returns}")
    end

    def to_s_internal : String
      "fn #{pretty_sig}"
    end
  end
end
