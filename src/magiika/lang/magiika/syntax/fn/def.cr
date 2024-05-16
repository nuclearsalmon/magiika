module Magiika::Lang::Syntax
  protected def define_fn(context : Context)
    pos = Position.default
    name_tok = context[:fn_ident].token
    name = name_tok.value

    node_params = context[:fn_params]?.try(&.nodes?)
    params = Node::FnParams.new
    unless node_params.nil?
      node_params.each { |node|
        node.type!(Node::FnParam)
        params << node.as(Node::FnParam)
      }
    end

    body = context[:fn_body].nodes
    ret_tok = context[:fn_ret]?.try(&.token.value)
    ret = nil  # FIXME

    fn = Node::StmtsFn.new(pos, name, params, body, ret)
    assign = Node::AssignVar.new(pos, name_tok, fn, AssignMode::Any)

    context.clear
    context.become(assign)
  end

  protected def register_function_defining
    group :fn_ident do
      rule :FN_T, :def do |context|
        context.become(:def)
      end

      rule :def
    end

    group :fn_params do
      rule :PAR
    end

    group :fn_ret do
      rule :IMPL, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :fn_stmt do
      rule :cond
      rule :fn_def
    end

    group :fn_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :fn_stmt, :fn_stmts do |context|
        context.flatten
      end
      rule :fn_stmt
    end

    group :fn_body do
      ignore(:NEWLINE)

      rule :BRC do |context|
        context.clear
      end

      rule :L_BRC, :fn_stmts, :R_BRC  do |context|
        context.become(:fn_stmts)
      end
    end

    group :fn_def do
      rule :fn_ident, :fn_params, :fn_ret, :fn_body do |context|
        define_fn(context)
      end

      rule :fn_ident, :fn_params, :fn_body do |context|
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
end