module Magiika::Syntax
  protected def self.define_class(context, abstract_ : ::Bool)
    name_t = context[:cls_ident].token
    name = name_t.value
    pos = name_t.position

    info_stmts = context[:cls_info_block].nodes? || [] of Ast
    body_stmts = context[:cls_body_block].nodes? || [] of Ast

    cls = Ast::DefineClass.new(name, abstract_, info_stmts, body_stmts, pos)

    context.become(cls)
  end
  
  define_syntax do
    group :cls_body_stmt do
      rule :define_abstract_instance_method
      rule :define_abstract_static_method
      rule :define_instance_method
      rule :define_static_method

      rule :define_class

      rule :instance_define_var
      rule :static_define_var
    end

    group :cls_body_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :cls_body_stmts, :cls_body_stmt do |context|
        context.absorb(:cls_body_stmts)
        context.absorb(:cls_body_stmt)
      end
      rule :cls_body_stmt
    end

    group :cls_body_block do
      inherited_ignore :NEWLINE

      rule :L_BRC, :R_BRC

      rule :L_BRC, :cls_body_stmts, :R_BRC do |context|
        context.become(:cls_body_stmts)
      end

      error_trap :L_BRC, "}"
    end

    group :cls_info_stmt do
      rule :EXTENDS, :NAME do |context|
        vp = context[:NAME].token.value_position
        value, position = vp[:value], vp[:position]
        stmt = Ast::ExtendsStmt.new(value, position)
        context.become(stmt)
      end
    end

    group :cls_info_stmts do
      inherited_ignore :NEWLINE
      inherited_ignore :INLINE_NEWLINE

      rule :cls_info_stmts, :cls_info_stmt do |context|
        context.absorb(:cls_info_stmts, overwrite_subcontexts: false)
        context.absorb(:cls_info_stmt, overwrite_subcontexts: false)
      end
      rule :cls_info_stmt
    end

    group :cls_info_block do
      rule :L_SQBRC, :R_SQBRC
      rule :L_SQBRC, :cls_info_stmts, :R_SQBRC do |context|
        context.become(:cls_info_stmts)
      end

      error_trap :L_SQBRC, "]"
    end

    group :cls_ident do
      rule :NAME
      rule :CLS_T, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :define_class do
      noignore :NEWLINE
      noignore :INLINE_NEWLINE

      rule :COLON, :cls_ident, :cls_info_block, :cls_body_block do |context|
        Syntax.define_class(context, abstract_: false)
      end

      rule :COLON, :ABSTRACT, :cls_ident, :cls_info_block, :cls_body_block do |context|
        Syntax.define_class(context, abstract_: true)
      end
    end
  end
end
