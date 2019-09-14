using BindingDebug

RSpec.describe BindingDebug do
  describe Binding do
    class TestOutput
      def to_s
        "to_s"
      end

      def inspect
        "inspect"
      end

      def pretty_inspect
        "pretty_inspect"
      end
    end

    describe "#debug" do
      subject { binding.debug expr }

      context "when capturing instance variables" do
        let!(:instance_value) { @instance_value = 42 }
        let(:expr) { "@instance_value" }
        it { is_expected.to eq "@instance_value : #{instance_value}" }
      end

      context "when capturing local variables" do
        let(:expr) { "local_value" }
        it do
          local_value = 42
          expect(binding.debug expr).to eq "local_value : #{local_value}"
        end
      end

      context "when capturing class variables" do
        let!(:class_value) { @@class_value = 42 }
        let(:expr) { "@@class_value" }
        it { is_expected.to eq "@@class_value : #{class_value}" }
      end

      context "when capturing expr" do
        let(:expr) { "42 + 42" }
        it { is_expected.to eq "42 + 42 : 84" }
      end

      context "when capturing method" do
        let(:meth) { 42 }
        let(:expr) { "meth" }
        it { is_expected.to eq "meth : #{meth}" }
      end

      context "when multiline expr" do
        let(:value1) { 42 }
        let(:value2) { 3.14 }
        let(:value3) { "homu" }
        let(:expr) {
          %{
            value1
            value2
            value3
          }
        }
        it { is_expected.to eq "value1 : #{value1}\nvalue2 : #{value2}\nvalue3 : #{value3}" }
      end

      context "when with block" do
        let(:mami) { "mami" }
        homu = "homu"
        it { expect(binding.debug(%{ mami + homu }){ |name, value| "#{name} - #{value}" }).to eq "mami + homu - mamihomu" }
      end
    end

    describe ".puts" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          binding.puts "TestOutput.new"
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : to_s\n" }
    end

    describe ".p" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          binding.p "TestOutput.new"
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : inspect\n" }
    end

    describe ".pp" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          binding.pp "TestOutput.new"
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : pretty_inspect\n" }
    end
  end

  describe Kernel do
    class TestOutput
      def to_s
        "to_s"
      end

      def inspect
        "inspect"
      end

      def pretty_inspect
        "pretty_inspect"
      end
    end

    describe ".puts" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          puts { TestOutput.new }
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : to_s\n" }
    end

    describe ".p" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          p { TestOutput.new }
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : inspect\n" }
    end

    describe ".pp" do
      let(:output) { StringIO.new }

      subject do
        proc do
          tmp = $stdout
          $stdout = output
          pp { TestOutput.new }
        ensure
          $stdout = tmp
        end
      end

      it { is_expected.to change { output.string }.to eq "TestOutput.new : pretty_inspect\n" }
    end
  end
end
