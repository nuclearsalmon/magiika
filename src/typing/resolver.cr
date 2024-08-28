module Magiika
  class Node::Resolver < Node
    include AutoEvalType

    getter ident : String

    @resolved_type : TypeNode? = nil
    @mutex : Mutex = Mutex.new

    def initialize(
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      @mutex.lock

      value = @resolved_type
      return value unless value.nil?

      meta = scope.retrieve?(@ident)
      if meta.nil?
        Node::Nil.instance
      else
        @resolved_type = meta.value
      end
    ensure
      @mutex.unlock
    end

    def to_s_internal : String
      str = "resolver for #{@ident}"

      resolved_type = @resolved_type
      unless resolved_type.nil?
        str += ",\nresolved value: #{resolved_type.to_s_internal}"
      end

      str
    end
  end
end
