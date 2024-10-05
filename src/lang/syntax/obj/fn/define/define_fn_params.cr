module Magiika::Syntax
  define_syntax do
    group :fn_param do
      rule :any_def, :ASSIGN, :cond do |context|
        name = context[:any_def][:NAME].token.value
        _type_t = context[:any_def][:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Node::Resolver.new(_type_t.value, _type_t.position))

        value = context[:cond].node
        position = context.first_position

        node = Node::FnParam.new(name, _type, nil, value, position)
        context.become(node)
      end

      rule :any_def do |context|
        name = context[:any_def][:NAME].token.value
        _type_t = context[:any_def][:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Node::Resolver.new(_type_t.value, _type_t.position))

        position = context.first_position

        node = Node::FnParam.new(name, _type, nil, nil, position)
        context.become(node)
      end
    end

    group :fn_params do
      ignore :SPACE

      rule :fn_param, :SEP, :fn_params do |context|
        context.drop(:SEP)
        context.flatten
      end
      rule :fn_param
    end

    group :_fn_params_block do
      ignore :NEWLINE

      rule :R_PAR

      rule :fn_params, :R_PAR do |context|
        context.become(:fn_params)
      end

      # error trap
      rule :fn_params do |context|
        position = context[:fn_params].nodes.last.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end

    group :fn_params_block do
      ignore :NEWLINE

      rule :L_PAR, :_fn_params_block do |context|
        context.become(:_fn_params_block)
      end

      # error trap
      rule :L_PAR do |context|
        position = context.token.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end
  end
end
