module Magiika
  class Node::ClsInst < InstTypeNode
    include SubscopingFeat

    delegate name, to: @cls

    @inst_scope : Scope::Cls
    @cls : Node::Cls

    def initialize(
        @cls : Node::Cls,
        args : FnArgs,
        position : Position? = nil)
      super(position)

      @inst_scope = Scope::Cls.new(
        @cls.name,
        @cls.cls_scope,
        position,
        @cls.inst_scope_base.variables)

      initialize_by_fn(args)
    end

    private def initialize_by_fn(args : FnArgs)
      init_fn = @cls.cls_scope.get("init")
      Util.is_a!(init_fn, Node::Fn)
      init_fn = init_fn.as(Node::Fn)

      init_fn.call_safe_raise(args, @inst_scope)
    end

    def type_name : String
      self.name
    end

    def superclass : Node::Cls
      @cls
    end

    def scope : Scope::Cls
      @inst_scope
    end

    # ⭐ Members
    # ---

    def []?(ident : String) : Node?
      meta = @inst_scope.get?(ident)
      meta = @cls.cls_scope.get?(ident) if meta.nil?
      return meta.as(Node::Meta).try(&.value)
    end

    # define members code
    private def self.def_fn(
        name : String,
        body : Proc(Scope::Fn, Node),
        params : FnParams? = nil,
        ret_type : TypeNode? = nil)
      params = FnParams.new if params.nil?
      params << FnParam.new("self", self)

      fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

      @inst_scope.set(name, NativeFn.new(name, params, body, fn_ret))
    end
  end
end
