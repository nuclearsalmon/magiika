module Magiika
  class ResourceLimits
    property max_time_seconds : Float64 = 0.0
    property max_memory_bytes : UInt64 = 0u64
    @start_time : Time::Instant = Time.instant

    def elapsed_seconds : Float64
      (Time.instant - @start_time).total_seconds
    end

    def time_remaining? : Float64?
      return nil if @max_time_seconds <= 0
      remaining = @max_time_seconds - elapsed_seconds
      remaining > 0 ? remaining : 0.0
    end

    def memory_used : UInt64
      GC.stats.heap_size
    end

    def check_limits! : ::Nil
      check_time!
      check_memory!
    end

    def check_time! : ::Nil
      return if @max_time_seconds <= 0
      if elapsed_seconds > @max_time_seconds
        raise Error::ResourceLimit.new(
          "Execution time limit exceeded (#{@max_time_seconds}s)")
      end
    end

    def check_memory! : ::Nil
      return if @max_memory_bytes <= 0
      if memory_used > @max_memory_bytes
        raise Error::ResourceLimit.new(
          "Memory limit exceeded (#{@max_memory_bytes} bytes)")
      end
    end
  end
end
