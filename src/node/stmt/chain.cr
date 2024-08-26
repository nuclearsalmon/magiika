module Magiika
  class Node::Chain < Node
    def initialize(@stmts : Array(Node), position : Position? = nil)
      super(position)
    end

    private def get_scope(node : Node) : Scope?
      node.scope if node.responds_to?(:scope)
    end

    private def unpack_meta(node : Node) : Node
      node.is_a?(Node::Meta) ? node.value : node
    end

    private def extract_scope(node : Node) : Scope
      scope = get_scope(node)
      if scope.nil?
        raise Error::Lazy.new("No scope for #{node.pretty_inspect}")
      end

      scope
    end

    def eval(scope : Scope) : Node
      with_node = @stmts[0].eval(scope)

      with_node = unpack_meta(with_node)
      with_scope = extract_scope(with_node)

      @stmts[1..].each_with_index(2) { |stmt, index|
        if stmt.is_a?(Node::Call)
          with_node = stmt.eval(with_scope, scope)
        else
          with_node = stmt.eval(with_scope)
        end

        if index < @stmts.size
          with_node = unpack_meta(with_node)
          with_scope = extract_scope(with_node)
        end
      }

      unpack_meta(with_node)
    end
  end
end
