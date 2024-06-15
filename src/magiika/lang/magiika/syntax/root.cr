module Magiika::Lang::Syntax
  protected def register_root
    root do
      ignore :LINE_CONT
      ignore :SPACE

      rule :stmts
    end

    group :stmts do
      rule :stmt, :NEWLINE, :stmts do |context|
        context.flatten

        root_node = Node::Root.new(context.nodes)

        context.become(root_node)
      end
      rule :stmt, :NEWLINE do |context|
        context.become(:stmt)
      end
      rule :stmt
    end

    group :stmt do
      rule :fn_def
      rule :cls_def
      rule :def_value
      rule :set_value
      rule :cond
    end

    group :value do
      rule :chain
      rule :value_nochain
    end

    group :value_nochain do
      rule :literal
      rule :fn_call
      rule :get_value
      rule :L_PAR, :enclosed_value, :R_PAR do |context|
        context.become(:enclosed_value)
      end
    end

    group :enclosed_value do
      rule :def_value
      rule :set_value
      rule :cond
    end
  end
end
