require 'helper'
require 'flipper/client'

describe Flipper::Client do
  subject { Flipper::Client.new(adapter) }

  let(:source)  { {} }
  let(:adapter) { Flipper::Adapters::Memory.new(source) }

  let(:admins_feature) { feature(:admins) }

  before do
    source.clear
  end

  def feature(name)
    Flipper::Feature.new(name, adapter)
  end

  describe "#enabled?" do
    before do
      subject.stub(:feature => admins_feature)
    end

    it "passes arguments to feature enabled check and returns result" do
      admins_feature.should_receive(:enabled?).with(:foo).and_return(true)
      subject.should_receive(:feature).with(:stats).and_return(admins_feature)
      subject.enabled?(:stats, :foo).should be_true
    end
  end

  describe "#disabled?" do
    it "passes all args to enabled? and returns the opposite" do
      subject.should_receive(:enabled?).with(:stats, :foo).and_return(true)
      subject.disabled?(:stats, :foo).should be_false
    end
  end

  describe "#enable" do
    before do
      subject.stub(:feature => admins_feature)
    end

    it "calls enable for feature with arguments" do
      admins_feature.should_receive(:enable).with(:foo)
      subject.should_receive(:feature).with(:stats).and_return(admins_feature)
      subject.enable :stats, :foo
    end
  end

  describe "#disable" do
    before do
      subject.stub(:feature => admins_feature)
    end

    it "calls disable for feature with arguments" do
      admins_feature.should_receive(:disable).with(:foo)
      subject.should_receive(:feature).with(:stats).and_return(admins_feature)
      subject.disable :stats, :foo
    end
  end

  describe "#feature" do
    before do
      @result = subject.feature(:stats)
    end

    it "returns instance of feature with correct name and adapter" do
      @result.should be_instance_of(Flipper::Feature)
      @result.name.should eq(:stats)
      @result.adapter.should eq(adapter)
    end

    it "memoizes the feature" do
      subject.feature(:stats).should equal(@result)
    end
  end
end
