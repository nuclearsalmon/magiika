module Magiika
  class Object::ClassInitMethod < Object::Function
    @statements : Array(Ast)

    def initialize(
        defining_scope : Scope,
        static : ::Bool,
        name : ::String,
        params : FnParams,
        @statements : Array(Ast),
        returns : FnRet? = nil,
        position : Position? = nil)
      super(defining_scope, static, name, params, returns, position)

      # scan statements for misplaced super call
      @statements[1..].each do |stmt|
        if stmt.is_a?(Ast::Call) && stmt.name == SUPER_METHOD_NAME
          raise Error::Internal.new("super call in init is only allowed as the first statement")
        end
      end

      # check if we need to inject implicit super call
      unless (
        @statements[0].is_a?(Ast::Fn) && 
        @statements[0].name == SUPER_METHOD_NAME)
        # injected super call
        @statements.unshift(Ast::Call.new(
          SUPER_METHOD_NAME,
          FnParams.new))
      end
    end

    protected def method_eval(
        method_scope : Scope) : AnyObject
      result : AnyObject = Object::Nil.instance
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      result
    end
  end
end