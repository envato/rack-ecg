RSpec.describe Rack::ECG::CheckFactory do
  class MyCheckClass; end
  class MyOtherCheckClass; def initialize(params); end; end

  let(:definitions) { [] }
  let(:default_checks) { [] }
  subject(:check_factory) { Rack::ECG::CheckFactory.new(definitions, default_checks: default_checks) }

  describe "#build" do
    context "with a class that does not take params" do
      let(:check_class) { spy(MyCheckClass) }

      it "builds the specified class" do
        expect { check_factory.build(check_class: check_class) }.not_to raise_error
        expect(check_class).to have_received(:new).with(no_args)
      end
    end

    context "with a class that does not take params" do
      let(:check_class) { spy(MyOtherCheckClass) }
      let(:check_parameters) { double }
      it "builds the specified class" do
        expect { check_factory.build(check_class: check_class, parameters: check_parameters) }.not_to raise_error
        expect(check_class).to have_received(:new).with(check_parameters)
      end
    end
  end

  describe "#build_all" do
    context "with defined checks" do
      let(:definitions) { [:my_check, [:my_other_check, {foo: 'bar'}]] }
      let(:check_class) { spy(MyCheckClass) }
      let(:other_check_class) { spy(MyOtherCheckClass) }
      before do
        allow(Rack::ECG::CheckRegistry).to receive(:lookup).with(:my_check).and_return(check_class)
        allow(Rack::ECG::CheckRegistry).to receive(:lookup).with(:my_other_check).and_return(other_check_class)
      end

      it "builds all registered checks" do
        check_factory.build_all
        expect(check_class).to have_received(:new).with(no_args)
        expect(other_check_class).to have_received(:new).with(foo: 'bar')
      end
    end

    context "with defined default checks" do
      let(:default_checks) { [:http] }
      let(:http_class) { spy(Rack::ECG::Check::Http) }
      before do
        allow(Rack::ECG::CheckRegistry).to receive(:lookup).with(:http).and_return(http_class)
      end

      it "builds registered default checks" do
        check_factory.build_all
        expect(http_class).to have_received(:new).with(no_args)
      end
    end
  end
end
