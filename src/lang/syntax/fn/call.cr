module Magiika::Syntax
  protected def register_function_call
    group :fn_arg do
      rule :value do |context|
        value = context.node

        node = Node::FnArg.new(value)
        context.become(node)
      end

      rule :NAME, :EQ, :value do |context|
        name = context[:NAME].token.value
        value = context[:value].node

        node = Node::FnArg.new(value, name)
        context.become(node)
      end
    end

    group :fn_args do
      rule :fn_arg, :SEP, :fn_args do |context|
        context.drop(:SEP)
        context.flatten
      end

      rule :fn_arg
    end

    group :fn_args_block do
      rule :PAR
      rule :L_PAR, :fn_args, :R_PAR do |context|
        context.become(:fn_args)
      end
    end

    group :fn_call do
      rule :get_value, :fn_args_block do |context|
        parse_fn(context)
      end
    end
  end

  protected def ensure_args_type(
      node_args : Array(Psuedo::Node)?) : FnArgs
    args = FnArgs.new
    node_args.try(&.each { |node|
      Util.is_a!(node, Node::FnArg)
      args << node.as(Node::FnArg)
    })
    args
  end

  protected def parse_fn(context : Merlin::Context(Symbol, Psuedo::Node))
    target = context[:get_value].node

    node_args = context[:fn_args_block].nodes?
    args = ensure_args_type(node_args)

    position = context.position
    node = Node::Call.new(position, target, args)
    context.become(node)
  end
end