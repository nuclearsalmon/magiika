module Magiika
  module Primitive
    include Ast

    # NOTE: A shim to ensure that even though this is an object and
    # thus doesn't require evaluation, it can still be used
    # in expressions the way one would expect.
    def eval(scope : Scope) : Object
      self
    end
  end

  abstract class PrimitiveType < Type
    include Primitive
  end

  abstract class PrimitiveInstance < Instance
    include Primitive
  end
end
