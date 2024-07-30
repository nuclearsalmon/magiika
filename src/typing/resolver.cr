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
      if value.nil?
        value = scope.get(@ident)
        @resolved_type = value
      end

      return value
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
