module Magiika::Lang::Syntax
  protected def register_functions
    # ✨ Defining
    # ------------------------------------------------------

    group(:fn_param) do
      rule(:NAME, :DEFINE, :NAME, :ASSIGN, :value) do |context|
        _type = context[:NAME].token(0)
        name = context[:NAME].token(1)
        value = context[:value].node

        Node::FnParam.new(
          name.value,
          Node::RetrieveVar.new(_type.position, _type),
          nil,
          value,
          name.position)
      end

      rule(:NAME, :DEFINE, :NAME) do |context|
        _type = context[:NAME].token(0)
        name = context[:NAME].token(0)

        Node::FnParam.new(
          name.value,
          Node::RetrieveVar.new(_type.position, _type),
          nil,
          nil,
          name.position)
      end

      rule(:NAME, :ASSIGN, :value) do |context|
        name = context[:NAME].token
        value = context[:value].node

        Node::FnParam.new(
          name.value,
          value.class,
          nil,
          value,
          name.position)
      end

      rule(:NAME) do |context|
        name = context[:NAME].token

        Node::FnParam.new(
          name.value,
          nil,
          nil,
          nil,
          name.position)
      end
    end

    group(:fn_params) do
      rule(:fn_param, :SEP, :fn_params) do |context|
        param = context[:fn_param].node
        params = context[:fn_params].nodes

        params << param

        context.clear
        context.add(params)
        nil
      end

      rule(:fn_param)
    end

    group(:fn_stmt_body) do
      ignore(:NEWLINE)

      rule(:L_BRC, :stmts, :R_BRC) do |context|
        stmts = context[:stmts].nodes

        context.clear
        context.add(:stmts, stmts)
        nil
      end
    end

    group(:fn_def_ident) do
      rule(:FN_TYP, :DEFINE, :NAME) do |context|
        name = context[:NAME].token

        context.clear
        context.add(:name, name)
        nil
      end

      rule(:DEFINE, :NAME) do |context|
        name = context[:NAME].token

        context.clear
        context.add(:name, name)
        nil
      end
    end

    group(:fn_def_params) do
      rule(:PAR) do |context|
        context.clear
        context.add(:params, Array(Node::FnParam).new)
        nil
      end

      rule(:L_PAR, :fn_params, :R_PAR) do |context|
        params = context[:fn_params].nodes()

        context.clear
        context.add(:params, params)
        nil
      end
    end

    group(:fn_def_lspec) do
      rule(:fn_def_ident, :fn_def_params) do |context|
        name = context[:name!].token
        params = context[:fn_def_params].nodes

        context.clear
        context.add(:name, name)
        context.add(:params, params)
        nil
      end
      rule(:fn_def_ident) do |context|
        name = context[:fn_def_ident].token

        context.clear
        context.add(:name, name)
        nil
      end
    end

    group(:fn_def_rspec) do
      rule(:IMPL, :NAME) do |context|
        ret_type = context[:NAME].token

        context.clear
        context.add(:ret_type, ret_type)
        nil
      end
    end

    group(:fn_def_spec) do
      rule(:fn_def_lspec, :fn_def_rspec) do |context|
        name = context[:NAME].token
        params = context[:params].nodes?
        ret_type = context[:RET_TYPE].token

        context.clear
        context.add(:name, name)
        context.add(:params, params) unless params.nil?
        context.add(:ret_type, ret_type)
        nil
      end

      rule(:fn_def_lspec)
    end

    group(:fn_def_abstract) do
      rule(:ABSTRACT, :fn_def_spec) do |context|
        name = context[:NAME].token
        params = context[:params].nodes
        ret_type = context[:RET_TYPE].token
        stmts = context[:stmts].nodes

        context.clear
        #Node::StatementFn.new(
        #  name.position,
        #  name.value,
        #  params.as(Array(Node::FnParam)),
        #  ret_type,
        #  stmts)
        nil
      end
    end

    group(:fn_def_immediate) do
      rule(:fn_def_spec, :fn_stmt_body) do |context|
        name = context[:NAME].token
        params = context[:params].nodes?
        ret_type = context[:RET_TYPE].token
        stmts = context[:stmts].nodes

        context.clear
        #Node::StatementFunction.new(
        #  name.position,
        #  name,
        #  params,
        #  ret_type,
        #  stmts)
        nil
      end
    end

    group(:fn_def) do
      rule(:fn_def_abstract)
      rule(:fn_def_immediate)
    end


    # ✨ Calling
    # ------------------------------------------------------

    group(:fn_arg) do
      rule(:NAME, :ASSIGN, :value) do |context|
        name = context[:NAME].token
        value = context[:value].node

        context.clear
        context.add(:name, name)
        context.add(:value, value)
        nil
      end

      rule(:value) do |context|
        value = context[:value].node

        context.clear
        context.add(:value, value)
        nil
      end
    end

    group(:fn_args) do
      rule(:fn_arg, :SEP, :fn_args) do |context|
        arg = context[:fn_arg].node
        args = context[:fn_args].nodes

        args << arg

        context.clear
        context.add(:args, args)
        nil
      end
      rule(:fn_arg) do |context|
        arg = context[:fn_arg].node

        context.clear
        context.add(:args, [arg])
        nil
      end
    end

    group(:fn_call) do
      rule(:NAME, :PAR) do |context|
      end

      rule(:NAME, :L_PAR, :fn_args, :R_PAR) do |context|
      end

      rule(:NAME) do |context|
      end
    end
  end
end
