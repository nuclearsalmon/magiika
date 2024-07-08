module Magiika
  class Node::Cls < TypeNode::DualTyping
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
      if !(Util.upcase?(@name[0]))
        raise Error::NamingConvention.new(
          "Class names must start with an uppercase character.")
      end
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

    def scope : Scope::Cls
      @cls_scope
    end

    def defining_scope : Scope
      @cls_scope.parent
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

      @cls_scope.set(name, NativeFn.new(name, params, body, fn_ret))
    end
  end
end
