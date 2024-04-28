module Magiika
  module Typing
    extend self

    TYPE_IDS = Hash(Int32, NodeType).new
    TYPE_REGISTRY_MUTEX = Mutex.new

    def register_type(reference : NodeType) : Int32
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

    def deregister_type(id : Int32)
      TYPE_REGISTRY_MUTEX.lock

      if TYPE_IDS.delete(id).nil?
        raise Error::Internal.new("Type ID #{id} does not exist.")
      end
    rescue ex
      raise Error::Internal.new("Error upon deregistering type: #{ex.pretty_inspect}")
    ensure
      TYPE_REGISTRY_MUTEX.unlock
    end

    # intended as a debugging method
    private def verify_id!(node : NodeObj)
      verify_id!(node.class)
    end

    # intended as a debugging method
    private def verify_id!(node : NodeType)
      claimed_id = node.type_id
      actual_node = TYPE_IDS[claimed_id]?

      # TODO: handle classes

      if actual_node.nil?
        raise Error::Internal.new(
          "Node #{node} (#{node.type_name} claims type ID #{claimed_id}), " +
          "but there exists no node under that ID")
      #elsif ((node.is_a?(Node::Class) && (actual_node.type_id != node.type_id)) || actual_node != node)
      elsif actual_node != node
        raise Error::Internal.new(
          "Node #{node} (#{node.type_name} claims type ID #{claimed_id}), " +
          "but the node at the claimed ID is registered as a #{actual_node}.")
      end
    end

    def exact_type?(target : NodeAny, _type : NodeType) : ::Bool
      target.type_id == _type.type_id
    end

    def type?(target : NodeAny, _type : NodeType) : ::Bool
      if _type.is_a?(Node::Union)
        union_type?(target, _type)
      else
        return true if exact_type?(target, _type)
        inherits_type?(target, _type, false)
      end
    end

    def union_type?(target : NodeAny, _union : Node::Union) : ::Bool
      _union.types.each { |_type|
        return true if type?(target, _type)
      }
      false
    end

    def inherits_type?(target : NodeAny, _type : NodeType, error : ::Bool = true) : ::Bool
      if !target.is_a?(NodeClassBase)
        raise Error::Internal.new("Target must be a #{NodeClassBase.class}.")
      end

      klass = target
      it_count = 0
      while klass.is_a?(NodeClassBase)
        klass = klass.superclass

        return true if exact_type?(klass, _type)

        it_count += 1
        if it_count > Magiika::INHERITANCE_LIMIT
          raise Error::Internal.new("Exceeded inheritance limit when looking up #{target}.")
        end
      end
      false
    end
  end
end
