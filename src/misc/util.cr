module Magiika::Util
  include CrystalUtils

  def obj_to_args!(
    obj : Object, 
    args : Array(Object::Argument),
    scope : Scope
  ) : Nil
    case obj
    when Instance
      args << Object::Argument.new(
        obj, scope, SELF_NAME)
      args << Object::Argument.new(
        obj.type, scope, THIS_NAME)
    else
      args << Object::Argument.new(
        obj, scope, THIS_NAME)
    end
  end
end
