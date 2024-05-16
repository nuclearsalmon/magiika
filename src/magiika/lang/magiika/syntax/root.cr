module Magiika::Lang::Syntax
  protected def register_root
    root do
      ignore :LINE_CONT
      ignore :SPACE

      rule :stmts
    end

    group :stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :stmt, :stmts do |context|
        context.flatten
        root_node = Node::Root.new(context.nodes)
        context.become(root_node)
      end
      rule :stmt
    end

    group :stmt do
      rule :fn_def
      rule :set_member_value
      rule :def_value
      rule :set_value
      rule :cond
    end

    group :value do
      rule :literal
      rule :fn_call
      rule :get_member_value
      rule :get_value
      rule :L_PAR, :cond, :R_PAR
    end
  end
end
