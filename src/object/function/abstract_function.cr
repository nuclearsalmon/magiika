class Magiika::Object
  class AbstractFunction < FunctionInstance
    protected def method_eval(method_scope : Scope) : Object
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def to_s_internal : ::String
      "abst fn #{pretty_sig}"
    end
  end
end
