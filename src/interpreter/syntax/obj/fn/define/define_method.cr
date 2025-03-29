module Magiika::Syntax
  protected def self.define_function(
    context, 
    abstract_ : ::Bool, 
    static : ::Bool
  )
    name_t = context[:function_name].token
    name = name_t.value
    position = name_t.position

    tmp_parameters = context[:function_data][:_parameters]?
    parameters : Array(Ast::Parameter) = tmp_parameters \
      .try(&.nodes.map do |parameter|
        raise Error::InternalType.new unless parameter.is_a?(Ast::Parameter)
        parameter.as(Ast::Parameter)
      end) || Array(Ast::Parameter).new

    returns = context[:function_data][:_returns]?.try(&.node)

    if abstract_
      function = Ast::DefineFunction.new(
        static: static,
        name: name,
        parameters: parameters,
        statements: nil,
        returns: returns,
        access: Access::Public,
        position: position
      )
      context.become(function)
    else
      body = context[:function_body].nodes

      function = Ast::DefineFunction.new(
        static: static,
        name: name,
        parameters: parameters,
        statements: body,
        returns: returns,
        access: Access::Public,
        position: position
      )
      context.become(function)
    end
  end
  
  define_syntax do
    # ⭐ Functions, instance and static methods ⭐
    # ------------------------------------------------------------------------

    group :define_function do
      ignore :NEWLINE
      rule :function_name, :function_data, :function_body
    end

    group :define_instance_method do
      rule :DOT, :define_function do |context|
        context.become(:define_function)
        Syntax.define_function(context, abstract_: false, static: false)
      end
    end

    group :define_static_method do
      rule :COLON, :define_function do |context|
        context.become(:define_function)
        Syntax.define_function(context, abstract_: false, static: true)
      end
    end

    
    # ⭐ Abstract methods ⭐
    # ------------------------------------------------------------------------

    group :define_abstract_method do
      ignore :NEWLINE

      rule :ABSTRACT, :function_name, :function_data

      rule :ABSTRACT, :define_function do |context|
        raise Error::ExpectedCharacter.new(
          "Abstract function cannot have a body.", 
          context.after_last_position
        )
      end
    end

    group :define_abstract_instance_method do
      rule :DOT, :define_abstract_method do |context|
        context.become(:define_abstract_method)
        Syntax.define_function(context, abstract_: true, static: false)
      end
    end

    group :define_abstract_static_method do
      rule :COLON, :define_abstract_method do |context|
        context.become(:define_abstract_method)
        Syntax.define_function(context, abstract_: true, static: true)
      end
    end
  end
end