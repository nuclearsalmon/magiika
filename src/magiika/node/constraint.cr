module Magiika::Constraints
  module Nilable
    property nilable : ::Bool = false

    def validate_nilable(node : NodeObj) : MatchResult
      return MatchResult.new(true) if @nilable || node.is_a?(Node::Nil)
      MatchResult.new(false, ["Node is not nilable"])
    end
  end

#  module Length
#    property min_len : Int32?
#    property max_len : Int32?
#
#    def validate_length(node : NodeObj) : MatchResult
#      _min_len = min_len
#      _max_len = max_len
#      if _min_len && node.length < _min_len
#        return MatchResult.new(false,
#          ["Length of node is less than the minimum length of #{_min_len}"])
#      end
#      if _max_len && node.length > _max_len
#        return MatchResult.new(false,
#          ["Length of node is greater than the maximum length of #{_max_len}"])
#      end
#      MatchResult.new(true)
#    end
#  end

#  module Range
#    property min_value : Int32?
#    property max_value : Int32?
#
#    def validate_range(node : NodeObj) : MatchResult
#      _min_value = min_value
#      _max_value = max_value
#      if _min_value && node < _min_value
#        return MatchResult.new(false,
#          ["Range of node is less than the minimum range of #{_min_value}"])
#      end
#      if _max_value && node > _max_value
#        return MatchResult.new(false,
#          ["Range of node is greater than the maximum range of #{_max_value}"])
#      end
#      MatchResult.new(true)
#    end
#  end

  module Characters
    property chr_whitelist : Set(Char)? = nil
    property chr_blacklist : Set(Char)? = nil

    def validate_characters(node : NodeObj) : MatchResult
      if node.responds_to?(:value)
        value = node.value
        if value.is_a?(String)
          value = value.as(String)

          _chr_blacklist = chr_blacklist
          _chr_whitelist = chr_blacklist
          if _chr_blacklist && value.chars.any? { |char| _chr_blacklist.includes?(char) }
            return MatchResult.new(false, ["String contains disallowed characters"])
          end
          if _chr_whitelist && value.chars.none? { |char| _chr_whitelist.includes?(char) }
            return MatchResult.new(false, ["String does not contain required characters"])
          end
        end
      end

      MatchResult.new(true)
    end
  end
end


module Magiika
  class Node::Constraint
    property _type : NodeAny?

    def initialize(@_type : NodeAny? = nil)
    end

    def validate(node : NodeObj) : MatchResult
      MatchResult.new(@_type.nil? || node.class == @_type)
    end

    def magic?
      @_type.nil?
    end
  end

  class Node::ConstConstraint < Node::Constraint
    def initialize()
      super(NodeType)  # All types of nodes can be const
    end

    def validate(node : NodeObj) : MatchResult
      MatchResult.new(true)
    end
  end

  class Node::StringConstraint < Node::Constraint
    include Constraints::Nilable
    #include Constraints::Length
    include Constraints::Characters

    def validate(node : NodeObj) : MatchResult
      result = MatchResult.new(true)
      result.merge!(validate_nilable(node))
      #result.merge!(validate_length(node))
      result.merge!(validate_characters(node))
      result
    end
  end

  class Node::NumberConstraint < Node::Constraint
    include Constraints::Nilable
#    include Constraints::Range

    def validate(node : NodeObj) : MatchResult
      result = MatchResult.new(true)
      result.merge!(validate_nilable(node))
#      result.merge!(validate_range(node))
      result
    end
  end

  class Node::ListConstraint < Node::Constraint
    include Constraints::Nilable
    #include Constraints::Length

    getter element_constraints : Array(Constraint)

    def initialize(
        @element_constraints : Array(Constraint))
      super(List)
    end

    def validate(node : NodeObj) : MatchResult
      result = MatchResult.new(true)
      result.merge!(validate_nilable(node))
      #result.merge!(validate_length(node))
      result
    end
  end
end
