require "binding/debug/version"
require "pp"

module BindingDebug
  module Formats
    module_function

    def default
      proc { |name, value| "#{name} # => #{value}" }
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
      result = nil
      puts(expr){ |name, value|
        result = value; block.call name, value.inspect
      }
      result
    end

    def pp expr, &block
      block ||= Formats.default
      result = nil
      puts(expr){ |name, value|
        result = value
        # MEMO: Remove \n in eol.
        block.call name, value.pretty_inspect.rstrip
      }
      result
    end

    def puts expr, &block
      Kernel.puts debug expr, &block
    end
  end

  module ProcWithBody
    refine RubyVM::InstructionSequence do
      def to_h
        %i(
          magic
          major_version
          minor_version
          format_type
          misc
          label
          path
          absolute_path
          first_lineno
          type
          locals
          args
          catch_table
          bytecode
        ).zip(to_a).to_h
      end
    end
    using self

    refine Proc do
      def body
        path, (start_lnum, start_col, end_lnum, end_col) = code_location

        raise "Unsupported file" if path.nil? || path == "(irb)"

        File.readlines(path).yield_self { |lines|
          start_line, end_line = lines[start_lnum-1], lines[end_lnum-1]

          # MEMO: Add support `-> { hoge }`
          start_col += start_line[(start_col+1)..-1].yield_self { |line|
              line =~ /^>\s*{/ ? line.index("{") + 1      # Support 2.5
            : line =~ /^\s*{/  ? line.index("{") + 1      # Support 2.6 or later
            : 0
          }

          if start_lnum == end_lnum
            start_line[(start_col)...(end_col)]
          elsif end_lnum - start_lnum == 1
            start_line[(start_col)..-1] + end_line[0...(end_col)]
          else
            start_line[(start_col)..-1] +
            lines[(start_lnum)...(end_lnum-1)].join +
            end_line[0...(end_col)]
          end.tap { |src|
            break $1 if src =~ /(?:^do(.+)end$)/m
            break $1 if src =~ /(?:^\s*{(.+)}$)/m
            break ""
          }
        }
      end

      def code_location
        RubyVM::InstructionSequence.of(self).to_h
          .yield_self { |iseq| [iseq[:absolute_path], iseq.dig(:misc, :code_range) || iseq.dig(:misc, :code_location)] }
      end
    end
  end

  refine Kernel do
    using ProcWithBody
    using BindingDebug

    def puts(*args, &block)
      return super(*args) if block.nil?
      block.binding.puts block.body
    end

    def p(*args, &block)
      return super(*args) if block.nil?
      block.binding.p block.body
    end

    def pp(*args, &block)
      return super(*args) if block.nil?
      block.binding.pp block.body
    end
  end
end
