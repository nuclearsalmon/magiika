class Magiika::Typing
  alias TypeID = Int32  # alias to allow for some future flexibility

  private START_TYPE_ID = 0i32.as(TypeID)
  private INC_TYPE_ID = 1i32.as(TypeID)
  @@next_type_id : TypeID = START_TYPE_ID.as(TypeID)

  private IDS_IN_USE = Set(TypeID).new
  private FREE_IDS = Deque(TypeID).new

  private MUTEX = Mutex.new

  def self.aquire_id : TypeID
    MUTEX.synchronize do
      unless FREE_IDS.empty?
        IDS_IN_USE << (id = FREE_IDS.shift); return id
      end

      if @@next_type_id < TypeID::MAX
        id = @@next_type_id
        @@next_type_id += INC_TYPE_ID
        IDS_IN_USE << id
        return id
      end

      id = START_TYPE_ID
      while IDS_IN_USE.includes?(id)
        if id == TypeID::MAX
          raise Error::Internal.new("Type ID space exhausted")
        end
        id += INC_TYPE_ID
      end

      IDS_IN_USE << id; return id
    end
  end

  def self.release_id(id : TypeID)
    MUTEX.synchronize do
      if IDS_IN_USE.delete(id).nil?
        raise Error::Internal.new("Type ID #{id} does not exist.")
      end

      FREE_IDS << id
    end
  end
end
