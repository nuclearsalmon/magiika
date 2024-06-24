module Magiika
  class Node::Cls < TypeNodeClass::ClassTyping::DualTyping
    include Psuedo::Resolved

    getter name : String
    getter cls_scope : Scope::Cls
    getter inst_scope_base : Scope::Cls

    def initialize(
        @name : String,
        @abstract : ::Bool,
        @cls_scope : Scope::Cls,
        @inst_scope_base : Scope::Cls,
        position : Position? = nil)
      super(position)
    end

    def abstract?
      @abstract
    end

    def eval(scope : Scope) : self
      self
    end

    def to_s_internal : String
      "cls #{@name}"
    end

    def type_name : String
      "Cls::#{@name}"
    end


    # ⭐ Members
    # ---

    def []?(ident : String) : Psuedo::Node?
      meta = @cls_scope.get?(ident)
      return meta.try(&.value)
    end

    # define members code
    private def self.def_fn(
        name : String,
        body : Proc(Scope::Fn, Psuedo::Node),
        params : FnParams? = nil,
        ret_type : Psuedo::TypeNode? = nil)
      params = FnParams.new if params.nil?
      params << FnParam.new("self", self)

      fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

      @cls_scope.set(name, NativeFn.new(name, params, body, fn_ret))
    end
  end
end
