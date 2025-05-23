module Magiika::Syntax
  define_syntax do
    group :fn_arg do
      rule :NAME, :EQ, :value do |context|
        name = context[:NAME].token.value
        value = context[:value].node

        node = Ast::Argument.new(value, name)
        context.become(node)
      end

      rule :value do |context|
        value = context.node

        node = Ast::Argument.new(value)
        context.become(node)
      end
    end

    group :fn_args do
      rule :fn_arg, :SEP, :fn_args do |context|
        context.drop(:SEP)
        context.flatten
      end

      rule :fn_arg
    end

    group :fn_args_block do
      ignore :NEWLINE

      rule :R_PAR

      rule :fn_args, :R_PAR do |context|
        context.become(:fn_args)
      end

      # error trap
      rule :fn_args do |context|
        position = context.last_position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end

    group :fn_call do
      ignore :NEWLINE

      rule :retrieve, :L_PAR, :fn_args_block do |context|
        target = context[:retrieve].node
        node_args = context[:fn_args_block].nodes?

        # ensure args type
        args = Array(Ast::Argument).new
        node_args.try(&.each { |node|
          Util.is_a!(node, Ast::Argument)
          args << node.as(Ast::Argument)
        })

        position = context.first_position
        node = Ast::Call.new(target, args, position)
        context.become(node)
      end

      # error trap
      rule :retrieve, :L_PAR do |context|
        position = context.last_position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end
  end
end