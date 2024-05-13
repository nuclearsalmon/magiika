require "./nested_scope.cr"


module Magiika
  class Scope::MethodScope < Scope::NestedScope
    def inject(args : Hash(String, NodeObj))
      args.each{ |name, value|
        set(name, value)
      }
    end
  end
end
