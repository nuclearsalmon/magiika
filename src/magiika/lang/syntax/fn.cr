module Magiika::Lang::Syntax
  protected def register_functions
    # ✨ Defining
    # ------------------------------------------------------

    group(:fn_param) do
      rule(:NAME, :DEFINE, :NAME, :ASSIGN, :value) do |context|
        _type = context.token(:NAME, 0)
        name = context.token(:NAME, 1)
        value = context.node(:value)
        
        Node::FnParam.new(
          name.pos,
          name.value, 
          Node::Constraint.new(Node::RetrieveVar.new(_type.pos, _type)),
          value.as(Node))
      end
      
      rule(:NAME, :DEFINE, :NAME) do |context|
        _type = context.token(:NAME, 0)
        name = context.token(:NAME, 1)

        Node::FnParam.new(
          name.pos,
          name.value, 
          Node::Constraint.new(Node::RetrieveVar.new(_type.pos, _type)))
      end

      rule(:NAME, :ASSIGN, :value) do |context|
        name = context.token(:NAME)
        value = context.node(:value)

        Node::FnParam.new(
          name.pos,
          name.value, 
          Node::Constraint.new,
          value)
      end

      rule(:NAME) do |context|
        name = context.token(:NAME)

        Node::FnParam.new(
          name.pos,
          name.value, 
          Node::Constraint.new)
      end
    end

    group(:fn_params) do
      rule(:fn_param, :SEP, :fn_params) do |context|
        param = context.node(:fn_param)
        params = context.nodes(:fn_params)

        params << param
        
        context.clear
        context.update(params)
        nil
      end

      rule(:fn_param)
    end

    group(:fn_stmt_body) do
      ignore(:NEWLINE)

      rule(:L_BRC, :stmts, :R_BRC) do |context|
        stmts = context.nodes(:stmts)

        context.clear
        context.update(:stmts, stmts)
        nil
      end
    end

    group(:fn_def_ident) do
      rule(:FN_TYP, :DEFINE, :NAME) do |context|
        name = context.token(:NAME)

        context.clear
        context.update(:name, name)
        nil
      end

      rule(:DEFINE, :NAME) do |context|
        name = context.token(:NAME)

        context.clear
        context.update(:name, name)
        nil
      end
    end

    group(:fn_def_params) do
      rule(:PAR) do |context|
        context.clear
        context.update(:params, Array(Node::FnParam).new)
        nil
      end

      rule(:L_PAR, :fn_params, :R_PAR) do |context|
        params = context.nodes(:fn_params)
        
        context.clear
        context.update(:params, params)
        nil
      end
    end

    group(:fn_def_lspec) do
      rule(:fn_def_ident, :fn_def_params) do |context|
        name = context.token(:name!)
        params = context.nodes(:fn_def_params)

        context.clear
        context.update(:name, name)
        context.update(:params, params)
        nil
      end
      rule(:fn_def_ident) do |context|
        name = context.token(:fn_def_ident)

        context.clear
        context.update(:name, name)
        nil
      end
    end

    group(:fn_def_rspec) do
      rule(:IMPL, :NAME) do |context|
        ret_type = context.token(:NAME)
        
        context.clear
        context.update(:ret_type, ret_type)
        nil
      end
    end

    group(:fn_def_spec) do
      rule(:fn_def_lspec, :fn_def_rspec) do |context|
        name = context.token(:NAME!)
        params = context.nodes?(:params!)
        ret_type = context.token(:RET_TYPE!)

        context.clear
        context.update(:name, name)
        context.update(:params, params) unless params.nil?
        context.update(:ret_type, ret_type)
        nil
      end

      rule(:fn_def_lspec)
    end

    group(:fn_def_abstract) do
      rule(:ABSTRACT, :fn_def_spec) do |context|
        name = context.token(:NAME!)
        params = context.nodes(:params!)
        ret_type = context.token(:RET_TYPE!)
        stmts = context.nodes(:stmts)

        context.clear
        #Node::StatementFn.new(
        #  name.pos,
        #  name.value,
        #  params.as(Array(Node::FnParam)),
        #  ret_type,
        #  stmts)
        nil
      end
    end

    group(:fn_def_immediate) do
      rule(:fn_def_spec, :fn_stmt_body) do |context|
        name = context.token(:NAME!)
        params = context.nodes?(:params!)
        ret_type = context.token(:RET_TYPE!)
        stmts = context.nodes(:stmts!)

        context.clear
        #Node::StatementFunction.new(
        #  name.pos,
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
        name = context.token(:NAME)
        value = context.node(:value)

        context.clear
        context.update(:name, name)
        context.update(:value, value)
        nil
      end

      rule(:value) do |context|
        value = context.node(:value)

        context.clear
        context.update(:value, value)
        nil
      end
    end

    group(:fn_args) do
      rule(:fn_arg, :SEP, :fn_args) do |context|
        arg = context.node(:fn_arg)
        args = context.nodes(:fn_args)

        args << arg

        context.clear
        context.update(:args, args)
        nil
      end
      rule(:fn_arg) do |context|
        arg = context.node(:fn_arg)

        context.clear
        context.update(:args, [arg])
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
