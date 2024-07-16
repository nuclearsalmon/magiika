module Magiika
  class Node::Resolve < Node
    getter ident : String

    @resolved_type : TypeNode? = nil
    @mutex : Mutex = Mutex.new

    def initialize(position : Position, @ident : String)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      @mutex.lock
      value = @resolved_type
      if value.nil?
        value = scope.get(@ident)
        @resolved_type = value
      end
      @mutex.unlock

      value
    end

    def to_s_internal : String
      value = @resolved_type
      if value.nil?
        "unresolved type \"#{@ident}\""
      else
        value.to_s_internal
      end
    end
  end
end
