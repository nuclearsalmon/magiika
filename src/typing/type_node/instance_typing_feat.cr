module Magiika::Typing
  macro instance_typing_feat
    include Typing::Type
    include Typing::TypeChecking
    include Typing::EvalsToType
    include Typing::RegistrableType

    def eval_type(scope : Scope) : Typing::Type
      eval(scope).as(Typing::Type)
    end

    @type_id : Typing::TypeID? = nil

    def type_id : Typing::TypeID
      type_id = @type_id
      if type_id.nil?
        raise Error::Internal.new("#{self.type_name} was never assigned an instance type id.")
      end
      type_id
    end

    def register_type : Typing::TypeID
      unless @type_id.nil?
        raise Error::Internal.new("#{self.type_name} already registered.")
      end

      type_id = Typing.register_type(self)
      @type_id = type_id
      type_id
    end

    def unregister_type : ::Nil
      type_id = @type_id
      if type_id.nil?
        raise Error::Internal.new("#{self.type_name} was never assigned an instance type id.")
      end
      Typing.unregister_type(type_id)
    end
  end
end