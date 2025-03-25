module Magiika::Syntax
  protected def self.define_fn(context, static : ::Bool)
    name_t = context[:any_fn_def].token
    name = name_t.value
    pos = name_t.position

    fn_def_ctx = context[:_define_fn]
    parameters = (
      fn_def_ctx[:_parameters]?.try(&.nodes) ||
      Array(Ast::Parameter).new)
      .as(Array(Ast::Parameter)?)
    body = fn_def_ctx[:_body].nodes
    ret = fn_def_ctx[:_ret]?.try(&.node)

    fn_ret = ret.as(Ast::Retrieve | Nil)

    fn = Ast::DefineFunction.new(
      static: static,
      name: name,
      parameters: parameters,
      statements: body,
      returns: fn_ret,
      access: Access::Public,
      position: pos)
    context.become(fn)
  end
  
  define_syntax do
    group :any_fn_def do
      rule :NAME
      rule :FN_T, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :fn_ret_t do
      rule :IMPL, :NAME do |context|
        name_t = context[:NAME].token
        pos = name_t.position
        name = name_t.value

        retrieve = Ast::Retrieve.new(name, pos)
        context.become(retrieve)
      end
    end

    group :_fn_parameters_block_and_strict_typing do
      rule :fn_parameters_block, :fn_ret_t do |context|
        parameters = context[:fn_parameters_block].nodes
        ret = context[:fn_ret_t].node

        context.clear
        context.add(:_parameters, parameters)
        context.add(:_ret, ret)
      end

      rule :fn_ret_t do |context|
        context.to_subcontext(:_ret)
      end
    end

    group :_fn_parameters_block_and_typing do
      rule :_fn_parameters_block_and_strict_typing

      rule :fn_parameters_block do |context|
        context.to_subcontext(:_parameters)
      end
    end

    group :_define_fn do
      rule :_fn_parameters_block_and_typing, :fn_body_block do |context|
        parameters : Array(Ast)? = context[:_parameters]?.try(&.nodes)
        ret = context[:_ret]?.try(&.node)
        body = context[:fn_body_block]?.try(&.nodes)

        context.clear
        context.add(:_parameters, parameters) unless parameters.nil?
        context.add(:_ret, ret) unless ret.nil?
        context.add(:_body, body) unless body.nil?
      end
    end

    group :define_fn do
      ignore :NEWLINE

      rule :any_fn_def, :_define_fn
    end

    group :instance_define_fn do
      rule :DOT, :define_fn do |context|
        context.become(:define_fn)

        Syntax.define_fn(context, false)
      end
    end

    group :static_define_fn do
      rule :COLON, :define_fn do |context|
        context.become(:define_fn)

        Syntax.define_fn(context, true)
      end
    end
  end
end