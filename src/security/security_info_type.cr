module Magiika
  # Magiika-facing singleton type that exposes security settings
  # to guest programs via native functions.
  #
  # Accessible in magiika as SecurityInfo with static methods:
  #   SecurityInfo.maxTime()         -> Int (seconds) or Nil
  #   SecurityInfo.maxMemory()       -> Int (bytes) or Nil
  #   SecurityInfo.timeElapsed()     -> Flt (seconds) or Nil
  #   SecurityInfo.timeRemaining()   -> Flt (seconds) or Nil
  #   SecurityInfo.memoryUsed()      -> Int (bytes) or Nil
  #
  # Each method respects the SecurityVisibility config:
  # hidden flags return Nil regardless of actual value.
  class Object::SecurityInfo < SingletonType
    @security_config : SecurityConfig

    def initialize(
      defining_scope : Scope,
      @security_config : SecurityConfig,
      position : Position? = nil
    )
      super(defining_scope, position: position)
    end

    def define : ::Nil
      super

      vis = @security_config.visibility
      limits = @security_config.resource_limits
      nil_t = defining_scope.definition(Object::Nil)
      int_t = defining_scope.definition(Type::Int)
      flt_t = defining_scope.definition(Type::Flt)

      def_native(name: "maxTime", static: true) do |_scope|
        if vis.visible?("max_time") && limits.max_time_seconds > 0
          int_t.create_instance(limits.max_time_seconds.to_i32)
        else
          nil_t.instance
        end
      end

      def_native(name: "maxMemory", static: true) do |_scope|
        if vis.visible?("max_memory") && limits.max_memory_bytes > 0
          bytes = limits.max_memory_bytes
          int_t.create_instance(
            bytes > Int32::MAX.to_u64 ? Int32::MAX : bytes.to_i32)
        else
          nil_t.instance
        end
      end

      def_native(name: "timeElapsed", static: true) do |_scope|
        if vis.visible?("time_elapsed")
          flt_t.create_instance(limits.elapsed_seconds.to_f32)
        else
          nil_t.instance
        end
      end

      def_native(name: "timeRemaining", static: true) do |_scope|
        if vis.visible?("time_remaining") && limits.max_time_seconds > 0
          remaining = limits.time_remaining?
          if remaining
            flt_t.create_instance(remaining.to_f32)
          else
            nil_t.instance
          end
        else
          nil_t.instance
        end
      end

      def_native(name: "memoryUsed", static: true) do |_scope|
        if vis.visible?("memory_used")
          used = limits.memory_used
          int_t.create_instance(
            used > Int32::MAX.to_u64 ? Int32::MAX : used.to_i32)
        else
          nil_t.instance
        end
      end
    end

    def to_s_internal : ::String
      "SecurityInfo"
    end
  end
end
