module Magiika
  abstract class UniqueType < Type
    include IsOf

    getter type_id : Typing::TypeID

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      @type_id = Typing.aquire_id
    end

    def finalize : ::Nil
      Typing.release_id(@type_id)
    end

    protected abstract def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance
  end
end
