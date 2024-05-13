module Magiika::FnTemplates
  module DefaultInjector
    protected def inject(args : Hash(String, NodeObj), scope : Scope::MethodScope)
      scope.inject(args)
    end
  end
end
