require "binding/debug/version"

module BindingDebug
  module Formats
    module_function
    def default
      proc { |name, value| "#{name} : #{value}" }
    end

    def inspect formatter = default
      proc { |name, value| formatter.call "#{name}.inspect", value.inspect }
    end

    def prefix str
      proc { |name, value| "#{str} #{BindingDebug::Formats.default.call name, value}" }
    end

    def suffix str
      proc { |name, value| "#{BindingDebug::Formats.default.call name, value} #{str}" }
    end
  end

  refine Binding do
    def debug expr, &block
      block ||= Formats.default
      binding = self
      expr.split("\n").reject { |it| /^\s*$/ =~ it }.map(&:strip).map { |expr|
        block.call(expr, binding.eval(expr))
      }.join("\n")
    end

    def p expr, &block
      block ||= Formats.default
      puts(expr){ |name, value| block.call name, value.inspect }
      expr
    end

    def puts expr, &block
      super debug expr, &block
    end
  end
end
