module Magiika::Typing
  extend self

  alias TypeID = Int32

  TYPE_IDS = Hash(TypeID, TypeMeta).new
  TYPE_REGISTRY_MUTEX = Mutex.new

  def register_type(
      type_name : ::String,
      reference : TypeNode.class | InstTypeNode,
      type_superclass : ::Class) : TypeMeta
    TYPE_REGISTRY_MUTEX.lock

    # look to see if reference already exists
    begin
      existing_type_meta = (TYPE_IDS.each_value.find { |meta|
        reference == meta.reference
      })
      return existing_type_meta unless existing_type_meta.nil?
    end

    # find lowest unused key
    id = 0i32
    while TYPE_IDS.has_key?(id)
      id += 1i32
    end

    type_meta = TypeMeta.new(id, type_name, reference, type_superclass)
    TYPE_IDS[id] = type_meta

    return type_meta
  rescue ex
    raise Error::Internal.new("Error upon registering type: #{ex.pretty_inspect}")
  ensure
    TYPE_REGISTRY_MUTEX.unlock
  end

  def unregister_type(id : TypeID)
    TYPE_REGISTRY_MUTEX.lock

    if TYPE_IDS.delete(id).nil?
      raise Error::Internal.new("Type ID #{id} does not exist.")
    end
  rescue ex
    raise Error::Internal.new("Error upon deregistering type: #{ex.pretty_inspect}")
  ensure
    TYPE_REGISTRY_MUTEX.unlock
  end
end
