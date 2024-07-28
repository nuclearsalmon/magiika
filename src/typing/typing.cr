module Magiika::Typing
  extend self

  alias TypeID = Int32

  TYPE_IDS = Hash(TypeID, Type).new
  TYPE_REGISTRY_MUTEX = Mutex.new

  def register_type(reference : Type) : TypeID
    TYPE_REGISTRY_MUTEX.lock

    # find lowest unused key
    id = 0
    while TYPE_IDS.has_key?(id)
      id += 1
    end

    # set reference to id
    TYPE_IDS[id] = reference

    return id
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
