module Magiika
  class AbstractFunctionInstance < Instance
    protected def method_eval(method_scope : Scope) : Object
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def object_name : ::String
      "abst #{@name}()"
    end
  end
end
