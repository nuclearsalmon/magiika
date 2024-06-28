module Magiika::Typing
  extend self

  alias TypeID = Int32

  TYPE_IDS = Hash(TypeID, NodeIdent).new
  TYPE_REGISTRY_MUTEX = Mutex.new

  def register_type(reference : NodeIdent) : TypeID
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

  # intended as a debugging method
  private def verify_id!(node : TypeNode)
    verify_id!(node.class)
  end

  # intended as a debugging method
  private def verify_id!(node : TypeNodeIdent)
    claimed_id = node.type_id
    actual_node = TYPE_IDS[claimed_id]?

    # TODO: handle classes

    if actual_node.nil?
      raise Error::Internal.new(
        "Node #{node} (#{node.type_name} claims type ID #{claimed_id}), " +
        "but there exists no node under that ID")
    #elsif ((node.is_a?(Node::Cls) && (actual_node.type_id != node.type_id)) || actual_node != node)
    elsif actual_node != node
      raise Error::Internal.new(
        "Node #{node} (#{node.type_name} claims type ID #{claimed_id}), " +
        "but the node at the claimed ID is registered as a #{actual_node}.")
    end
  end

  def union_type?(target : TypeNode, _union : Node::Union) : ::Bool
    _union.types.each { |_type|
      return true if type?(target, _type)
    }
    false
  end

  def union_type!(target : TypeNode, _union : Node::Union)
    if !union_type?(target, _type)
      raise Error::Type.new(target, _type, "Expected union type")
    end
  end

  private def inherits_type(
      target : TypeNode,
      _type : TypeNodeIdent,
      error : ::Bool = true) : ::Bool
    if !target.is_a?(Node)
      raise Error::Internal.new("Target must be a #{Node.class}.")
    end

    klass = target
    it_count = 0
    while klass.is_a?(Node)
      klass = klass.superclass

      return false if klass.nil?
      return true if exact_type?(klass, _type)

      it_count += 1
      if it_count > Magiika::INHERITANCE_LIMIT
        raise Error::Internal.new("Exceeded inheritance limit when looking up #{target}.")
      end
    end
    false
  end

  def inherits_type?(
      target : TypeNode,
      _type : TypeNodeIdent) : ::Bool
    inherits_type(target, _type, false)
  end

  def inherits_type!(
      target : TypeNode,
      _type : TypeNodeIdent,
      error : ::Bool = true)
    if !inherits_type(target, _type, error)
      raise Error::Type.new(target, _type, "Expected inheriting type")
    end
  end

  def exact_type?(
      target : TypeNode,
      _type : TypeNodeIdent) : ::Bool
    target.type_id == _type.type_id
  end

  def exact_type!(
      target : TypeNode,
      _type : TypeNodeIdent)
    if !exact_type?(target, _type)
      raise Error::Type.new(target, _type, "Expected exact type")
    end
  end

  def type?(
      target : TypeNode,
      _type : TypeNodeIdent) : ::Bool
    if _type.is_a?(Node::Union)
      union_type?(target, _type)
    else
      return true if exact_type?(target, _type)
      inherits_type(target, _type, false)
    end
  end

  def type!(
      target : TypeNode,
      _type : TypeNodeIdent) : ::Nil
    if !type?(target, _type)
      raise Error::Type.new(target, _type)
    end
  end

  def ident?(target : Node, ident : String) : ::Bool
    if target.is_a?(Node::Resolver | Node::RetrieveVar)
      target_ident = target.as(Node::Resolver | Node::RetrieveVar).ident
      return target_ident == ident
    else
      return false
    end
  end
end
