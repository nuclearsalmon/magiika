module Magiika
  module Typing
    extend self

    TYPE_IDS = Hash(Int32, NodeType).new
    TYPE_REGISTRY_MUTEX = Mutex.new

    def register_type(reference : NodeType) : Int32
      id : Int32

      begin
        TYPE_REGISTRY_MUTEX.lock

        id = TYPE_IDS.size
        TYPE_IDS[id] = reference
      rescue ex
        raise Error::Internal.new("Error upon registering type: #{ex.pretty_inspect}")
      ensure
        TYPE_REGISTRY_MUTEX.unlock
      end

      return id
    end

    def deregister_type(id : Int32)
      begin
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

    def node_is_an_exact?(_type : NodeType) : ::Bool
    end

    def node_is_a?(_type : NodeType) : ::Bool
    end

    def node_inherits_from?(_type : NodeType) : ::Bool
    end
  end
end
