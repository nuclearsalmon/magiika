module Magiika::Lang::Syntax
  protected def register_chaining
    group :chain do
      rule :value_nochain, :CHAIN, :NAME, :fn_args_block do |context|
        source = context[:value_nochain].node
        parse_chained_call(source, context)
      end

      rule :chain, :CHAIN, :NAME, :fn_args_block do |context|
        source = context[:chain].node
        parse_chained_call(source, context)
      end

      rule :value_nochain, :CHAIN, :NAME do |context|
        source = context[:value_nochain].node
        parse_chained_retrieve(source, context)
      end

      rule :chain, :CHAIN, :NAME do |context|
        source = context[:chain].node
        parse_chained_retrieve(source, context)
      end
    end

    # cls: c { :f { "hi" }}
  end

  protected def parse_chained_call(
      source : Psuedo::Node,
      context : Context) : Nil
    target_ident, position = \
      parse_chain_node_base(context)

    node_args = context[:fn_args_block].nodes?
    args = ensure_args_type(node_args)

    node = Node::ChainedCall.new(
      source, target_ident, args, position)
    context.become(node)
  end

  protected def parse_chained_retrieve(
      source : Psuedo::Node,
      context : Context) : Nil
    target_ident, position = \
      parse_chain_node_base(context)

    node = Node::ChainedRetrieve.new(
      source, target_ident, position)
    context.become(node)
  end

  protected def parse_chain_node_base(context : Context) \
      : Tuple(String, Position)
    target_ident_t = context[:NAME].token
    target_ident = target_ident_t.value
    position = target_ident_t.position

    {target_ident, position}
  end
end
