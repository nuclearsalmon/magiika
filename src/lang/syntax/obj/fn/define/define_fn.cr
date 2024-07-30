module Magiika::Syntax
  protected def register_define_fn
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

        retrieve = Node::Resolver.new(name, pos)
        context.become(retrieve)
      end
    end

    group :_fn_params_block_and_strict_typing do
      rule :fn_params_block, :fn_ret_t do |context|
        params = context[:fn_params_block].nodes
        ret = context[:fn_ret_t].node

        context.clear
        context.add(:_params, params)
        context.add(:_ret, ret)
      end

      rule :fn_ret_t do |context|
        context.to_subcontext(:_ret)
      end
    end

    group :_fn_params_block_and_typing do
      rule :_fn_params_block_and_strict_typing

      rule :fn_params_block do |context|
        context.to_subcontext(:_params)
      end
    end

    group :_define_fn do
      rule :_fn_params_block_and_typing, :fn_body_block do |context|
        params = context[:_params].nodes
        ret = context[:_ret]?.try(&.node)
        body = context[:fn_body_block]?.try(&.nodes)

        context.clear
        context.add(:_params, params)
        context.add(:_ret, ret) unless ret.nil?
        context.add(:_body, body) unless body.nil?
      end

      rule :fn_body_block do |context|
        context.to_subcontext(:_body) unless context.empty?
      end
    end

    group :define_fn do
      ignore :NEWLINE

      rule :any_fn_def, :_define_fn do |context|
        name_t = context[:any_fn_def].token
        name = name_t.value
        pos = name_t.position

        fn_def_ctx = context[:_define_fn]
        params = (
          fn_def_ctx[:_params]?.try(&.nodes) ||
          FnParams.new)
          .as(Array(Node::FnParam)?)
        body = fn_def_ctx[:_body].nodes
        ret = fn_def_ctx[:_ret]?.try(&.node)
        fn_ret = FnRet.new(_type: ret.as(TypeNode))

        fn = Node::DefFn.new(pos, name, params, body, fn_ret)
        context.become(fn)
      end
    end

    group :global_define_fn do
      rule :S_QUOT, :define_fn do |context|
        context.become(:define_fn)
      end
    end

    group :instance_define_fn do
      rule :DOT, :define_fn do |context|
        context.become(:define_fn)
      end
    end

    group :static_define_fn do
      rule :COLON, :define_fn do |context|
        context.become(:define_fn)
      end
    end
  end
end