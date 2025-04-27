module Magiika::Util
  include CrystalUtils

  def obj_to_args!(obj : AnyObject, args : Array(Object::Argument)) : Nil
    # Note: Avoid doing this on Magiika::Object.class. It's fine on Magiika::Object.
    unless obj.is_a?(Magiika::Object.class)
      args << Object::Argument.new(obj, SELF_NAME)
      args << Object::Argument.new(obj.class, THIS_NAME)
    else
      args << Object::Argument.new(obj, THIS_NAME)
    end
  end
end
