module Magiika::Typing
  macro class_typing_feat
    extend Typing::Type
    extend Typing::TypeChecking
    extend Typing::EvalsToType

    def self.eval_type(scope : Scope) : Typing::Type
      if self.is_a?(Typing::Type)
        self.as(Typing::Type)
      else
        raise Error::Lazy.new("wrong type")
      end
    end

    private macro recursive_inherited
      {% verbatim do %}
        # register self
        @@type_id : Int32 = Magiika::Typing.register_type(
          self.as(Typing::Type))

        def self.type_id : Typing::TypeID
          @@type_id
        end

        def type_id : Typing::TypeID
          self.class.type_id
        end

        macro inherited
          recursive_inherited
        end
      {% end %}
    end

    recursive_inherited
  end
end