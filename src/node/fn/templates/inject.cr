module Magiika::FnTemplates
  # Default implementation of argument scope injector
  # for function calls.
  module DefaultInjector
    protected def inject(args : Hash(String, TypeNode)) : ::Nil
      @defining_scope.inject(args)
    end
  end
end
