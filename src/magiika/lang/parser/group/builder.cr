module Magiika::Lang
  class Group::Builder
    @name : Symbol
    @rules = Array(Rule).new
    @lr_rules = Array(Rule).new
    @ignores = Array(Symbol).new
    @noignores : Array(Symbol)? = nil

    def self.new(name : Symbol, &)
      with Group.new(name) yield
    end

    def initialize(@name : Symbol)
    end

    def build : Group
      Group.new(
        @name, @rules, @lr_rules, @ignores, @noignores)
    end

    private def rule(rule : Rule)
      if rule.pattern[0] == @name
        rule.pattern.shift
        @lr_rules << rule
      else
        @rules << rule
      end
    end

    private def rule(pattern : Symbol)
      rule(Rule.new([pattern], nil))
    end

    private def rule(*pattern : Symbol)
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Symbol, &block : RuleBlock)
      rule(Rule.new([pattern], block))
    end

    private def rule(*pattern : Symbol, &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    private def rule(pattern : Array(Symbol))
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Array(Symbol), &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    private def ignore(pattern : Symbol)
      @ignores << pattern
    end

    private def noignore()
      noignores = @noignores
      @noignores = Array(Symbol).new if noignores.nil?
    end

    private def noignore(pattern : Symbol)
      noignores = @noignores
      if noignores.nil?
        noignores = Array(Symbol).new
        @noignores = noignores
      end
      noignores << pattern
    end
  end
end
