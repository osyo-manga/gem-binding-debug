require_relative "../spec_helper"

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
        it { is_expected.to eq "@instance_value # => #{instance_value}" }
      end

      context "when capturing local variables" do
        let(:expr) { "local_value" }
        it do
          local_value = 42
          expect(binding.debug expr).to eq "local_value # => #{local_value}"
        end
      end

      context "when capturing class variables" do
        let!(:class_value) { @@class_value = 42 }
        let(:expr) { "@@class_value" }
        it { is_expected.to eq "@@class_value # => #{class_value}" }
      end

      context "when capturing expr" do
        let(:expr) { "42 + 42" }
        it { is_expected.to eq "42 + 42 # => 84" }
      end

      context "when capturing method" do
        let(:meth) { 42 }
        let(:expr) { "meth" }
        it { is_expected.to eq "meth # => #{meth}" }
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
        it { is_expected.to eq "value1 # => #{value1}\nvalue2 # => #{value2}\nvalue3 # => #{value3}" }
      end

      context "when with block" do
        let(:mami) { "mami" }
        homu = "homu"
        it { expect(binding.debug(%{ mami + homu }){ |name, value| "#{name} - #{value}" }).to eq "mami + homu - mamihomu" }
      end
    end

    describe ".puts" do
      let(:args) { "TestOutput.new" }
      subject { -> { binding.puts args } }
      it { is_expected.to output("TestOutput.new # => to_s\n").to_stdout }
    end

    describe ".p" do
      let(:args) { "TestOutput.new" }
      subject { -> { binding.p args } }
      it { is_expected.to output("TestOutput.new # => inspect\n").to_stdout }
    end

    describe ".pp" do
      let(:args) { "TestOutput.new" }
      subject { -> { binding.pp args } }
      it { is_expected.to output("TestOutput.new # => pretty_inspect\n").to_stdout }

      context "multiline" do
        let(:args) { <<~EOS }
          1
          TestOutput.new
          2 + 3
          TestOutput.new
          3 + 4 + 5
          TestOutput.new
        EOS
        subject { -> { binding.pp args } }
        it { is_expected.to output(<<~EOS).to_stdout }
          1 # => 1
          TestOutput.new # => pretty_inspect
          2 + 3 # => 5
          TestOutput.new # => pretty_inspect
          3 + 4 + 5 # => 12
          TestOutput.new # => pretty_inspect
        EOS
      end
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
      subject { -> { puts &block } }

      context "when capturing TestOutput.new" do
        let(:block) { -> { TestOutput.new } }
        it { is_expected.to output("TestOutput.new # => to_s\n").to_stdout }
      end

      context "when capturing multiline" do
        let(:value) { 42 }
        let(:block) {
          value = 42
          -> {
            value
            value + value
          }
        }

        it { is_expected.to output("value # => 42\nvalue + value # => 84\n").to_stdout }
      end
    end

    describe ".p" do
      let(:block) { -> { TestOutput.new } }
      subject { -> { p &block } }
      it { is_expected.to output("TestOutput.new # => inspect\n").to_stdout }
    end

    describe ".pp" do
      let(:block) { -> { TestOutput.new } }
      subject { -> { pp &block } }
      it { is_expected.to output("TestOutput.new # => pretty_inspect\n").to_stdout }
    end
  end

  describe ::BindingDebug::ProcWithBody do
    using ::BindingDebug::ProcWithBody

    it { expect(proc{hoge}.body).to eq "hoge" }
    it { expect(proc{hoge }.body).to eq "hoge " }
    it { expect(proc{ hoge}.body).to eq " hoge" }
    it { expect(proc{ hoge }.body).to eq " hoge " }
    it { expect(proc{ -> { hoge } }.body).to eq " -> { hoge } " }
    it { expect(proc   { hoge }.body).to eq " hoge " }
    it { expect(proc { 		hoge }.body).to eq " 		hoge " }
    xit { expect(proc{ あああ }.body).to eq " あああ " }
    it do
       expect(proc { hoge
                     foo
       }.body).to eq " hoge\n                     foo\n       "
    end
    it do
       expect(proc { hoge
       }.body).to eq " hoge\n       "
    end
    it do
       expect(proc { hoge
                     foo }.body).to eq " hoge\n                     foo "
    end
    it do
       expect(proc { hoge
                     foo
                     bar }.body).to eq " hoge\n                     foo\n                     bar "
    end

    it { expect(proc do hoge end.body).to eq " hoge " }
    it { expect(proc do  hoge end.body).to eq "  hoge " }
    it { expect(proc do  -> { hoge } end.body).to eq "  -> { hoge } " }
    it { expect(proc     do hoge end.body).to eq " hoge " }
    it { expect(proc do		hoge end.body).to eq "		hoge " }
    xit { expect(proc do あああ end.body).to eq " あああ " }
    it do
       expect(proc { hoge
                     foo
       }.body).to eq " hoge\n                     foo\n       "
    end
    it do
       expect(proc { hoge
       }.body).to eq " hoge\n       "
    end
    it do
       expect(proc { hoge
                     foo }.body).to eq " hoge\n                     foo "
    end
    it do
       expect(proc { hoge
                     foo
                     bar }.body).to eq " hoge\n                     foo\n                     bar "
    end

    it { expect(lambda{hoge}.body).to eq "hoge" }
    it { expect(lambda{hoge }.body).to eq "hoge " }
    it { expect(lambda{ hoge}.body).to eq " hoge" }
    it { expect(lambda{ hoge }.body).to eq " hoge " }
    it { expect(lambda{ -> { hoge } }.body).to eq " -> { hoge } " }
    it { expect(lambda   { hoge }.body).to eq " hoge " }
    it { expect(lambda { 		hoge }.body).to eq " 		hoge " }

    it { expect(->{hoge}.body).to eq "hoge" }
    it { expect(->{hoge }.body).to eq "hoge " }
    it { expect(->{ hoge}.body).to eq " hoge" }
    it { expect(->{ hoge }.body).to eq " hoge " }
    it { expect(->{ -> { hoge } }.body).to eq " -> { hoge } " }
    it { expect(->   { hoge }.body).to eq " hoge " }
    it { expect(-> { 		hoge }.body).to eq " 		hoge " }
  end
end
