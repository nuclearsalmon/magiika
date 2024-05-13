module Magiika::FnTemplates
  module DefaultValidator
    protected def validate_result(result : NodeObj)
      returns = @returns
      unless returns.nil?
        # type check
        _type = returns._type
        if !_type.nil? && !result.type?(_type)
          raise Error::InternalType.new
        end

        # descriptor check
        descs = returns.descs
        unless descs.nil?
          descs.each do |descriptor|
            validation_result = descriptor.validate(result)
            unless validation_result.matched?
              validation_result.raise
            end
          end
        end
      end
    end
  end
end
