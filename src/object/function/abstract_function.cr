module Magiika
  class Object::AbstractFunction < Object::Function
    def initialize(*args, **kwargs)
      super(*args, **kwargs)
    end

    protected def method_eval(method_scope : Scope) : AnyObject
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def to_s_internal : ::String
      "abst fn #{pretty_sig}"
    end
  end
end
