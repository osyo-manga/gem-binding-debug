using BindingDebug

RSpec.describe BindingDebug do
  describe "#debug" do
    subject { binding.debug expr_str }

    context "when capturing instance variables" do
      let!(:instance_value) { @instance_value = 42 }
      let(:expr_str) { "@instance_value" }
      it { is_expected.to eq "@instance_value : #{instance_value}" }
    end

    context "when capturing local variables" do
      let(:expr_str) { "local_value" }
      it do
        local_value = 42
        expect(binding.debug expr_str).to eq "local_value : #{local_value}"
      end
    end

    context "when capturing class variables" do
      let!(:class_value) { @@class_value = 42 }
      let(:expr_str) { "@@class_value" }
      it { is_expected.to eq "@@class_value : #{class_value}" }
    end

    context "when capturing expr" do
      let(:expr_str) { "42 + 42" }
      it { is_expected.to eq "42 + 42 : 84" }
    end

    context "when capturing method" do
      let(:meth) { 42 }
      let(:expr_str) { "meth" }
      it { is_expected.to eq "meth : #{meth}" }
    end

    context "with block" do
      homu = "homu"
      it { expect(binding.debug(%{ mami + homu }){ |name, value| "#{name} - #{value}" }).to eq "mami + homu - mamihomu" }
    end
  end
end
