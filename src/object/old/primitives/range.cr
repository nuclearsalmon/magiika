module Magiika
  class Instance::Range < Instance
    getter start_value : InternalIntegerType
    getter end_value : InternalIntegerType
    getter? inclusive : ::Bool

    def initialize(
      @start_value : InternalIntegerType,
      @end_value : InternalIntegerType,
      @inclusive : ::Bool,
      type : Type::Range,
      position : Position? = nil
    )
      super(type, position)
    end

    def effective_end : InternalIntegerType
      @inclusive ? @end_value : @end_value - 1
    end

    def to_array(int_type : Type::Int) : ::Array(Object)
      result = ::Array(Object).new
      (@start_value..effective_end).each do |i|
        result << int_type.create_instance(i)
      end
      result
    end

    def to_s_internal : ::String
      op = @inclusive ? ".." : "..."
      "#{@start_value}#{op}#{@end_value}"
    end

    def eval_bool(scope : Scope) : ::Bool
      @start_value <= effective_end
    end
  end

  class Type::Range < GenericType(Instance::Range)
    def define : ::Nil
      super

      bool_type = defining_scope.definition(Type::Bool)
      int_type = defining_scope.definition(Type::Int)
      str_type = defining_scope.definition(Type::Str)
      list_type = defining_scope.definition(Type::List)

      def_native(
        name: "start",
        returns: int_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        int_type.create_instance(self_inst.start_value)
      end

      def_native(
        name: "end",
        returns: int_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        int_type.create_instance(self_inst.end_value)
      end

      def_native(
        name: "len",
        returns: int_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        len = self_inst.effective_end - self_inst.start_value + 1
        int_type.create_instance(len < 0 ? 0i32 : len)
      end

      def_native(
        name: "inclusive",
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        bool_type.create_instance(self_inst.inclusive?)
      end

      def_native(
        name: "to_list",
        returns: list_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        elements = self_inst.to_array(int_type)
        list_type.create_instance(elements)
      end

      def_native(
        name: "contains",
        parameters: [
          Object::Parameter.new(self.scope, "value", int_type)
        ],
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        val = scope.retrieve("value").value.as(Instance::Int).value
        bool_type.create_instance(val >= self_inst.start_value && val <= self_inst.effective_end)
      end

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(self.scope, "other", self)
        ],
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        other_inst = scope.retrieve("other").value.as(Instance::Range)
        equal = self_inst.start_value == other_inst.start_value &&
          self_inst.end_value == other_inst.end_value &&
          self_inst.inclusive? == other_inst.inclusive?
        bool_type.create_instance(equal)
      end

      def_native(
        name: "to_s",
        returns: str_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Range)
        str_type.create_instance(self_inst.to_s_internal)
      end
    end
  end
end
