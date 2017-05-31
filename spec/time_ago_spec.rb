RSpec.describe "TimeHelper" do
  subject { Object.new.extend(TimeHelper) }

  describe "#time_ago" do
    it "returns 'just now' when delta is less than 120" do
      result = subject.time_ago(0, 119)
      expect(result).to eq("just now")
    end

    it "returns '2 minutes ago' when delta is 120 seconds" do
      result = subject.time_ago(0, 120)
      expect(result).to eq("2 mintues ago")
    end

    it "returns '2 hours ago' when delta is 7200 seconds (60 * 60 * 2)" do
      result = subject.time_ago(0, 7200)
      expect(result).to eq("2 hours ago")
    end

    it "returns '2 days ago' when delta is 172800 seconds (60 * 60 * 24 * 2)" do
      result = subject.time_ago(0, 172800)
      expect(result).to eq("2 days ago")
    end

    it "returns '2 years ago' when delta is 63072000 seconds (60 * 60 * 24 * 365 * 2)" do
      result = subject.time_ago(0, 63072000)
      expect(result).to eq("2 years ago")
    end
  end
end
