using BindingDebug

RSpec.describe BindingDebug do
  describe "#debug" do
    let(:mami) { "mami" }
    context "default" do
      hoge = 42
      it { expect(binding.debug "hoge").to eq "hoge : 42" }
      homu = "homu"
      it { expect(binding.debug "homu.upcase").to eq "homu.upcase : HOMU" }
      it { expect(binding.debug %{ homu + homu }).to eq "homu + homu : homuhomu" }

      it { expect(binding.debug %{ mami + homu }).to eq "mami + homu : mamihomu" }
    end

    context "with block" do
      homu = "homu"
      it { expect(binding.debug(%{ mami + homu }){ |name, value| "#{name} - #{value}" }).to eq "mami + homu - mamihomu" }
    end
  end
end
