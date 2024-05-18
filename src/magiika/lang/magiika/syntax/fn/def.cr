module Magiika::Lang::Syntax
  protected def register_function_defining
    group :fn_ident do
      rule :FN_T, :def do |context|
        context.become(:def)
      end
      rule :def
    end

    group :fn_param do
      rule :t_def, :ASSIGN, :expr do |context|
        define_fn_param(context)
      end
      rule :t_def do |context|
        define_fn_param(context)
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

    group :fn_params_block do
      rule :PAR
      rule :L_PAR, :fn_params, :R_PAR do |context|
        context.become(:fn_params)
      end
    end

    group :fn_ret do
      rule :IMPL, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :fn_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :stmt, :fn_stmts do |context|
        context.flatten
      end
      rule :stmt
    end

    group :fn_body do
      ignore(:NEWLINE)

      rule :BRC
      rule :L_BRC, :fn_stmts, :R_BRC  do |context|
        context.become(:fn_stmts)
      end
    end

    group :fn_def do
      rule :fn_ident, :fn_params_block, :fn_ret, :fn_body do |context|
        define_fn(context)
      end

      rule :fn_ident, :fn_params_block, :fn_body do |context|
        define_fn(context)
      end

      rule :fn_ident, :fn_ret, :fn_body do |context|
        define_fn(context)
      end

      rule :fn_ident, :fn_body do |context|
        define_fn(context)
      end
    end
  end

  protected def define_fn(context : Context)
    pos = Position.default
    name_tok = context[:fn_ident].token
    name = name_tok.value

    node_params = context[:fn_params_block]?.try(&.nodes?)
    params = Node::FnParams.new
    unless node_params.nil?
      node_params.each { |node|
        node.type!(Node::FnParam)
        params << node.as(Node::FnParam)
      }
    end

    body = context[:fn_body].nodes?
    body = Array(NodeObj).new if body.nil?
    ret_tok = context[:fn_ret]?.try(&.token.value)
    ret = nil  # FIXME

    fn = Node::StmtsFn.new(pos, name, params, body, ret)
    assign = Node::AssignVar.new(pos, name_tok, fn, AssignMode::Any)

    context.clear
    context.become(assign)
  end

  protected def define_fn_param(context : Context)
    t_def = context[:t_def]?
    t_def = context if t_def.nil?

    _type_ident = t_def[:TYPE]?.try(&.token)
    name = t_def[:NAME].token.value

    _type = nil
    unless _type_ident.nil?
      _type = Node::RetrieveVar.new(_type_ident.value, _type_ident.position)
    end

    value = context[:expr]?.try(&.node)

    position = context.position

    node = Node::FnParam.new(name, _type, nil, value, position)
    context.become(node)
  end
end