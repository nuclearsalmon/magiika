module Magiika::Lang::Syntax
  protected def register_root
    root do
      ignore :LINE_CONT
      ignore :SPACE

      rule :stmts
    end

    group :stmts do
      rule :stmt, :nls, :stmts do |context|
        context.drop(:nls)
        context.flatten

        root_node = Node::Root.new(context.nodes)

        context.drop_nodes
        context.add(root_node)
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
      rule :L_PAR, :enclosed_value, :R_PAR do |context|
        context.become(:enclosed_value)
      end
    end

    group :enclosed_value do
      rule :set_member_value
      rule :def_value
      rule :set_value
      rule :cond
    end
  end
end
