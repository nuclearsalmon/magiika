module Magiika
  class Node::Chain < Node
    def initialize(@stmts : Array(Node), position : Position? = nil)
      super(position)
    end

    private def get_scope(node : Node) : Scope?
      node.scope if node.responds_to?(:scope)
    end

    def eval(scope : Scope) : Node
      with_node = @stmts[0].eval(scope)
      with_scope = get_scope(with_node)
      if with_scope.nil?
        raise Error::Lazy.new("No scope for #{with_node.pretty_inspect}")
      end

      @stmts[1..].each_with_index(2) { |stmt, index|
        if stmt.is_a?(Node::Call)
          with_node = stmt.eval(with_scope, scope)
        else
          with_node = stmt.eval(with_scope)
        end

        if index < @stmts.size
          with_scope = get_scope(with_node)

          if with_scope.nil?
            raise Error::Lazy.new("No scope for #{with_node.pretty_inspect}")
          end
        end
      }

      return with_node
    end
  end
end
