module Magiika::Lang::Syntax
  protected def register_functions
    # ✨ Defining
    # ------------------------------------------------------

    group(:fn_param) do
      rule(:NAME, :DEF, :NAME, :ASSIGN, :value) do |(_type,_,name,_), value|
        type(value, Node)
        Node::FnParam.new(
          name.pos,
          name, 
          Node::Constraint.new(_type),
          value.as(Node))
      end
      
      rule(:NAME, :DEF, :NAME) do |(_type,_,name), _|
        Node::FnParam.new(
          name.pos,
          name, 
          Node::Constraint.new(_type))
      end

      rule(:NAME, :ASSIGN, :value) do |(name,_,value), _|
        Node::FnParam.new(
          name.pos,
          name, 
          Node::Constraint.new(),
          value)
      end

      rule(:NAME) do |(name), _|
        Node::FnParam.new(
          name.pos,
          name, 
          Node::Constraint.new())
      end
    end

    group(:fn_params) do
      rule(:fn_param, :SEP, :fn_params) do |_, (param, params)|
        type(param, Node)
        type(params, Array(Node))
        params << param
      end

      rule(:fn_param) do |_, (param)|
        type(param, Node)
        Array(Node).new(param)
      end
    end

    group(:fn_stmt_body) do
      ignore(:NEWLINE)

      rule(:L_BRC, :stmts, :R_BRC) do |_, stmts|
        type(stmts, Array(Node))
        stmts
      end
    end

    group(:fn_def_blank_base) do
      rule(:DEF, :NAME, :PAR) do |(_, name_, _), _|
        # something
      end

      rule(:DEF, :NAME, :L_PAR, :fn_params, :R_PAR) do |(_,name,_,_), params|
        # something
      end
      rule(:FN_TYP, :DEF, :NAME) do |(_,_,name), _|
        # something
      end
    end

    group(:fn_def_blank) do
      rule(:fn_def_blank_base, :IMPL, :NAME) do |_, (base, ret)|
        # something
      end

      rule(:fn_def_blank_base) do |_, (base)|
        # something
      end
    end

    group(:fn_def_abstract) do
      rule(:ABSTRACT, :fn_def_blank) do |_, (base)|
        Node::StatementFunction.new(
          base.pos,
          base.name,
          base.params,
          base.returns)
      end
    end

    group(:fn_def_immediate) do
      rule(:fn_def_blank, :fn_stmt_body) do |_, (base, stmts)|
        Node::StatementFunction.new(
          base.pos,
          base.name,
          base.params,
          base.returns,
          stmts)
      end
    end

    group(:fn_def) do
      rule(:fn_def_abstract)
      rule(:fn_def_immediate)
    end


    # ✨ Calling
    # ------------------------------------------------------

    group(:fn_arg) do
      rule(:NAME, :ASSIGN, :value)
      rule(:value)
    end

    group(:fn_args) do
      rule(:fn_arg, :SEP, :fn_args) do |_, (arg, args)|
        # ...
      end
      rule(:fn_arg)
    end

    group(:fn_call) do
      rule(:NAME, :PAR) do |(name,_),_|
      end
      rule(:NAME, :L_PAR, :fn_args, :R_PAR) do |(name,_,_), args|
      end
      rule(:NAME) do |(name),_|
      end
    end
  end
end
