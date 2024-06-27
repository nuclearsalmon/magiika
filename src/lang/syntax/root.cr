module Magiika::Syntax
  protected def register_root
    root do
      ignore :COMMENT
      ignore :SPACE
      ignore :LINE_CONT
      ignore_trailing :NEWLINE
      ignore_trailing :INLINE_NEWLINE
      ignore_trailing :LINE_CONT

      rule :stmts do |context|
        context.become(:stmts)

        filename = context.node(0).position.filename

        root_node = Node::Stmts.new(
          context.nodes,
          Position.new(0,0, filename))
        context.become(root_node)
      end
    end

    group :stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :stmts, :stmt do |context|
        context.absorb(:stmts)
      end
      rule :stmt
    end

    group :stmt do
      rule :if_else
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