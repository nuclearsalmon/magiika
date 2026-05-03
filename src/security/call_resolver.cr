module Magiika
  def inject_arguments(
    function : FunctionInstance,
    owner_scope : Scope,
    arguments : Arguments
  ) : ::Nil
    if owner_scope.is_a?(ObjectScope)
      owner = owner_scope.as(ObjectScope).owner
      case owner
      in Type
        arguments.insert({"this", owner})
      in Instance
        arguments.insert({"self", owner})
        arguments.insert({"this", owner.type})
      end
    end
  end

  def call(name : ::String, arguments : Arguments, caller_scope : Scope)
    function, owner_scope = caller_scope.resolve_function(name, arguments)

    inject_arguments(function, owner_scope, arguments)

    function.call(arguments)
  end
end
