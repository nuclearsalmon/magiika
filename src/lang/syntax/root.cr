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
        filename = context.node(0).position.filename

        root_node = Node::Stmts.new(
          context.nodes,
          Position.new(0,0, filename))
        context.become(root_node)
      end
    end

    group :stmt do
      rule :if_else
      rule :global_define_fn
      #rule :define_cls
      rule :global_define_var
      rule :assign
      rule :cash_stmt

      rule :cond
    end

    group :stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :stmts, :stmt do |context|
        context.absorb(:stmts)
        context.absorb(:stmt)
      end
      rule :stmt
    end

    group :cash_stmt do
      rule :CASH, :stmt do |context|
        position = context[:CASH].token.position
        stmt = context[:stmt].node
        node = Node::CashPrint.new(position, stmt)

        context.become(node)
      end
    end

    group :value do
      rule :chain
      rule :value_nochain
    end

    group :value_nochain do
      rule :literal
      rule :fn_call
      rule :retrieve
      rule :L_PAR, :enclosed_value, :R_PAR do |context|
        context.become(:enclosed_value)
      end

      rule :L_PAR, :enclosed_value do |context|
        position = context[:enclosed_value].nodes.last.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end

      rule :L_PAR do |context|
        position = context.token.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end

    group :enclosed_value do
      rule :global_define_var
      rule :assign
      rule :cond
    end
  end
end
