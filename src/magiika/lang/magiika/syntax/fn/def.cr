module Magiika::Lang::Syntax
  protected def define_fn(context : Context) : NodeObj
    pos = Position.default
    name_tok = context[:fn_ident].token
    name = name_tok.value

    node_params = context[:fn_params].nodes?
    params = Node::FnParams.new
    unless node_params.nil?
      node_params.each { |node|
        node.type!(Node::FnParam)
        params << node.as(Node::FnParam)
      }
    end

    body = context[:fn_body].nodes
    #ret = context[:fn_ret]?.token.value
    ret = nil

    fn = Node::StmtsFn.new(pos, name, params, body, ret)
    Node::DeclareVar.new(pos, name_tok, fn)
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

    group :fn_stmts do
      rule :cond
      rule :fn_def
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
        fn_def = define_fn(context)
        context.clear
        context.add(fn_def)
      end

      rule :fn_ident, :fn_params, :fn_body do |context|
        fn_def = define_fn(context)
        context.clear
        context.add(fn_def)
      end
    end
  end
end