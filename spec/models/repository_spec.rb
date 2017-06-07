RSpec.describe "Repository" do
  let!(:ci_server) do
    Repository.create({
      name: "radavis/ci-server",
      url: "https://github.com/radavis/ci-server.git",
      build_instructions: "bundle && rake"
    })
  end

  let!(:sagan) do
    Repository.create({
      name: "radavis/sagan",
      url: "https://github.com/radavis/ci-server.git",
      build_instructions: ""
    })
  end

  let!(:exloc) do
    Repository.create({
      name: "exloc/app",
      url: nil,
      build_instructions: "bundle && rake"
    })
  end

  describe ".configured" do
    it "returns records where url and build_instructions are populated" do
      expect(Repository.configured).to include(ci_server)
      expect(Repository.configured).to_not include(sagan)
      expect(Repository.configured).to_not include(exloc)
    end
  end

  describe ".with_url" do
    it "returns records where url is populated" do
      expect(Repository.with_url).to include(ci_server)
      expect(Repository.with_url).to include(sagan)
      expect(Repository.with_url).to_not include(exloc)
    end
  end

  describe ".with_build_instructions" do
    it "returns records where the build_instructions are populated" do
      expect(Repository.with_build_instructions).to include(ci_server)
      expect(Repository.with_build_instructions).to_not include(sagan)
      expect(Repository.with_build_instructions).to include(exloc)
    end
  end
end
