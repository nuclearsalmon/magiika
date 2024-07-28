module Magiika::Syntax
  protected def register_chaining
    # TODO: change :value_nochain and :chain to just :value,
    #        and test if that works.
    group :chain do
      rule :value_nochain, :DOT, :NAME, :fn_args_block do |context|
        source = context[:value_nochain].node
        parse_chained_call(source, context)
      end

      rule :chain, :DOT, :NAME, :fn_args_block do |context|
        source = context[:chain].node
        parse_chained_call(source, context)
      end

      rule :value_nochain, :DOT, :NAME do |context|
        source = context[:value_nochain].node
        parse_chained_retrieve(source, context)
      end

      rule :chain, :DOT, :NAME do |context|
        source = context[:chain].node
        parse_chained_retrieve(source, context)
      end
    end
  end

  protected def parse_chain_target(
      context : Merlin::Context(Symbol, Node)) : Tuple(String, Position)
    target_ident_t = context[:NAME].token
    target_ident = target_ident_t.value
    position = target_ident_t.position

    {target_ident, position}
  end

  protected def parse_chained_call(
      source : Node,
      context : Merlin::Context(Symbol, Node)) : Nil
    target_ident, position = parse_chain_target(context)

    args = (context[:fn_args_block].nodes? || FnArgs.new).as(FnArgs)

    node = Node::ChainedCall.new(
      source, target_ident, args, position)
    context.become(node)
  end

  protected def parse_chained_retrieve(
      source : Node,
      context : Merlin::Context(Symbol, Node)) : Nil
    target_ident, position = parse_chain_target(context)

    node = Node::ChainedRetrieve.new(
      source, target_ident, position)
    context.become(node)
  end
end
