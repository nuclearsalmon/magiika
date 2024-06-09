module Magiika::Lang::Syntax
  protected def register_class_defining
    group :cls_ident do
      #rule :ABST, :CLS_T, :def do |context|
      #  context.drop(:CLS_T)
      #  context.absorb(:def)
      #end

      rule :CLS_T, :def do |context|
        context.become(:def)
      end

      #rule :ABST, :def do |context|
      #  context.absorb(:def)
      #end
    end

    group :cls_body do
      ignore(:NEWLINE)

      rule :BRC
      rule :L_BRC, :stmts, :R_BRC  do |context|
        context.become(:stmts)
      end
    end

    group :cls_def do
      rule :cls_ident, :cls_body do |context|
        define_cls(context)
      end
    end
  end

  protected def define_cls(context : Context)
    abst = !(context[:ABST]?.try(&.token?).nil?)

    name_t = context[:cls_ident].token
    name = name_t.value
    pos = name_t.position

    body = context[:cls_body].nodes?
    body = Array(Psuedo::Node).new if body.nil?

    def_cls = Node::DefCls.new(name, abst, body, pos)

    context.clear
    context.become(def_cls)
  end

  protected def define_fn_param(context : Context)
    t_def = context[:t_def]?
    t_def = context if t_def.nil?

    _type_ident = t_def[:TYPE]?.try(&.token)
    name = t_def[:NAME].token.value

    _type = nil
    unless _type_ident.nil?
      _type = Node::Resolve.new(_type_ident.value, _type_ident.position)
    end

    value = context[:expr]?.try(&.node)

    position = context.position

    node = Node::FnParam.new(name, _type, nil, value, position)
    context.become(node)
  end
end