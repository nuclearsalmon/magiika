module Magiika::Syntax
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
      rule :L_BRC, :R_BRC

      rule :L_BRC, :stmts, :R_BRC  do |context|
        context.become(:stmts)
      end

      rule :L_BRC, :stmts do |context|
        position = context[:stmts].nodes.last.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end

      rule :L_BRC do |context|
        position = context.token.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end

    group :cls_def do
      rule :cls_ident, :cls_body do |context|
        define_cls(context)
      end
    end
  end

  protected def define_cls(context : Merlin::Context(Symbol, Node))
    abst = !(context[:ABST]?.try(&.token?).nil?)

    name_t = context[:cls_ident].token
    name = name_t.value
    pos = name_t.position

    body = context[:cls_body].nodes?
    body = Array(Node).new if body.nil?

    def_cls = Node::DefCls.new(name, abst, body, pos)

    context.clear
    context.become(def_cls)
  end
end