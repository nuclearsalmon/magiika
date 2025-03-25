# AI Comment:
# Magiika::MetaObject represents objects that have both a static type ID
# (shared across their implementation, like Object) and a unique instance
# type ID (unique to each instance). These are used for objects that need
# to maintain their own type identity, such as classes, modules, or other
# type-defining constructs. Unlike regular Objects where all instances
# share the same type ID, each instance of a MetaObject can have its own
# unique type behavior.

abstract class Magiika::MetaObject < Magiika::Object
  getter type_id : Typing::TypeID
  @dupe : Magiika::MetaObject?

  # If the dupe is not provided, it will
  # aquire a new type ID for the object.
  # If the dupe is provided, it will use the ID provided by the dupe.
  def initialize(@dupe : Magiika::MetaObject? = nil, position : Position? = nil)
    super(position)

    if (dupe = @dupe).nil?
      #begin
        @type_id = Typing.aquire_id
      #rescue ex : Exception
      #  Typing::release_id(@type_id)
      #  raise ex
      #end
    else
      @type_id = dupe.type_id
    end
  end

  # Called when object is garbage collected. Releases the type ID. 
  # What this means in practice is that we can safely dupe an ID 
  # without worrying about it being released, as long as we also 
  # maintain a reference to the original holder of the ID. Failure to do
  # so will result in invalid type IDs.
  def finalize : ::Nil
    if @dupe.nil?
      Typing.release_id(@type_id)
    end
  end

  def is_of?(other : Magiika::AnyObject) : ::Bool
    if other.responds_to?(:type_id)
      other.type_id == self.type_id
    else
      false
    end
  end
end
