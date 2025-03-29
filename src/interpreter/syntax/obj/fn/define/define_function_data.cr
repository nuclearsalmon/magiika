module Magiika::Syntax
  define_syntax do
    group :function_parameter do
      rule :any_def, :ASSIGN, :cond do |context|
        name = context[:any_def][:NAME].token.value
        _type_t = context[:any_def][:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Ast::Retrieve.new(_type_t.value, position: _type_t.position))

        value = context[:cond].node
        position = context.first_position

        node = Ast::Parameter.new(name, value, _type, position: position)
        context.become(node)
      end

      rule :any_def do |context|
        name = context[:NAME].token.value
        _type_t = context[:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Ast::Retrieve.new(_type_t.value, position: _type_t.position))

        position = context.first_position

        node = Ast::Parameter.new(name, Object::Nil.instance, _type, position: position)
        context.become(node)
      end
    end

    group :function_parameters do
      ignore :SPACE

      rule :function_parameter, :SEP, :function_parameters do |context|
        context.drop(:SEP)
        context.flatten
      end
      rule :function_parameter
    end

    group :function_parameters_block do
      ignore :NEWLINE

      rule :L_PAR, :R_PAR

      rule :L_PAR, :function_parameters, :R_PAR do |context|
        context.become(:function_parameters)
      end

      rule :L_PAR, :function_parameters do |context|
        position = context[:function_parameters].nodes.last.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    
      # error trap
      rule :L_PAR do |context|
        position = context.token.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end

    group :function_return_type do
      rule :IMPL, :NAME do |context|
        name_t = context[:NAME].token
        pos = name_t.position
        name = name_t.value

        retrieve = Ast::Retrieve.new(name, pos)
        context.become(retrieve)
      end
    end

    group :function_data do
      rule :function_parameters_block, :function_return_type do |context|
        parameters = context[:function_parameters_block].nodes
        returns = context[:function_return_type].node

        context.clear
        context.add(:_parameters, parameters)
        context.add(:_returns, returns)
      end

      rule :function_return_type do |context|
        context.to_subcontext(:_returns)
      end

      rule :function_parameters_block do |context|
        context.to_subcontext(:_parameters)
      end
    end

    group :function_name do
      rule :NAME
      rule :FN_T, :NAME do |context|
        context.become(:NAME)
      end
    end
  end
end
