module Magiika::Checks
  extend self
  
  def function_name(name : ::String) : ::Nil
    raise Error::NamingConvention.new(
      "function name must start with a lowercase character"
    ) unless Util.downcase?(@name[0])
  end
  
  def parameters(params : Array(Parameter)) : ::Nil
    # Check that there are no param duplicates
    Set(::String).new.tap { |set|
      params.each { |param|
        # Remove ** and * prefixes for kwargs/nargs
        param_name = param.name.lchop("**").lchop("*")
        
        raise Error::Internal.new(
          "parameter names must be unique: '#{name}'"
        ) unless set.add?(param_name)
      }
    }
    
    # check that there are only one kwarg arg
    begin
      found_kwarg = false
      found_narg = false
      params.each { |param|
        if param.name.starts_with?("**")
          if found_kwarg
            raise Error::Internal.new(
              "more than one kwarg (\"**\") parameter")
          else
            found_kwarg = true
          end
        elsif param.name.starts_with?('*')
          if found_narg
            raise Error::Internal.new(
              "more than one narg (\"*\") parameter")
          else
            found_narg = true
          end
        end
      }
    end
  end
  
  def class_name(name : ::String) : ::Nil
    if !(Util.upcase?(@name[0]))
      raise Error::NamingConvention.new(
        "class name must start with a lowercase character")
    end
  end
end