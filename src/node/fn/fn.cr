module Magiika
  abstract class Node::Fn < TypeNode::ClassTyping
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
        position : Position,
        @name : String,
        @params : FnParams,
        @returns : FnRet? = nil)
      # FIXME: check that there are no param duplicates
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      self
    end

    def match_args(
        args : FnArgs,
        deep_analysis : ::Bool = false) \
        : {MatchResult, Hash(String, Node)?}
      anon_args = Array(Node).new
      kw_args = Hash(String, Node).new
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

      arg_to_param_mapping = Hash(String, Node).new
      match_result = MatchResult.new

      @params.each do |param|
        p_name = param.name
        arg_data : Node? = nil

        # figure out what type of parameter this is
        # and handle the argument accordingly
        if p_name.starts_with?("**")
          # FIXME: Implement kwargs, need hash node first
          raise Error::NotImplemented.new("kwargs not implemented")
        elsif p_name.starts_with?("*")
          arg_data = List.new(anon_args)
          anon_args.clear
        else
          arg_data = kw_args.delete(p_name)
          if arg_data.nil?
            arg_data = anon_args.pop?
            if arg_data.nil?
              p_value = param.value
              if p_value.nil?
                match_result.add_error("Missing argument for parameter \"#{p_name}\"")
                break unless deep_analysis
                next
              else
                arg_data = p_value
              end
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
          match_result.add_error("Duplicate argument for parameter \"#{p_name}\"")
          break unless deep_analysis
          next
        end

        # map
        arg_to_param_mapping[p_name] = arg_data
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

    abstract def call(
      args : Hash(String, TypeNode),
      scope : Scope) : TypeNode

    def call_safe(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | TypeNode
      match_result, node_args_hash = match_args(args, deep_analysis)

      return match_result unless match_result.matched?
      raise Error::Internal.new("Unexpected nil.") if node_args_hash.nil?

      type_node_args_hash = Hash(String, TypeNode).new
      node_args_hash.each { |key, value|
        type_value = value.eval(scope)
        unless type_value.is_a?(TypeNode)
          raise Error::Internal.new(
            "Expected TypeNode, " +
            "got #{type_value} from #{value}.")
        end
        type_node_args_hash[key] = type_value
      }

      call(type_node_args_hash, scope)
    end

    def call_safe_raise(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : TypeNode
      result = call_safe(args, scope, deep_analysis)

      result.as(MatchResult).raise if result.is_a?(MatchResult)
      return result.as(TypeNode)
    end

    def pretty_sig
      "#{@name}(" + \
        (@params.map { |param|
          param_value = param.value
          cs_map_str = ""
          param.descriptors.try(&.map { |descriptor|
            "#{descriptor.class.pretty_inspect}"
          }.join(separator='\n'))

          "\n  :" +
          cs_map_str +
          (cs_map_str == "" ? "" : " ") +
          param.name.to_s +
          (param_value.nil? ? "" : " = #{param_value.to_s_internal}")
        }).join(separator=",") + \
        ")" + \
        (@returns.nil? ? "" : "-> #{@returns}")
    end

    def to_s_internal : String
      "fn #{pretty_sig}"
    end
  end
end
