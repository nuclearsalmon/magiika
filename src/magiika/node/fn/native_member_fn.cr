module Magiika
  class Node::NativeMemberFn < Node::Fn
    def initialize(
        @parent : NodeObj,
        name : String,
        params : FnParams,
        @proc : Proc(Scope::MethodScope, NodeObj),
        returns : FnRet? = nil)
      super(name, params, returns)
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      # Inject args into scope
      method_scope = Scope::MethodScope.new(@name, position, scope)
      args.each do |name, value|
        method_scope.set(name, value)
      end
      method_scope.set("self", @parent)
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
end
