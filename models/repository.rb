class Repository < ActiveRecord::Base
  class << self
    def configured
      with_url.with_build_instructions
    end

    def with_url
      where.not(url: [nil, ""])
    end

    def with_build_instructions
      where.not(build_instructions: [nil, ""])
    end
  end

  has_many :events
  has_many :builds
end
