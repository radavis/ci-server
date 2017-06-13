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
  has_many :builds, through: :events

  def configured?
    self.class.configured.include?(self)
  end

  def instructions
    configuration_instructions.split("\r\n") + build_instructions.split("\r\n")
  end
end
