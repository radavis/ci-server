module TimeHelper
  def now
    Time.new.to_i
  end

  def time_ago(seconds, now = Time.now.to_i)
    minutes = (now - seconds) / 60
    quantity = [minutes / 525600, minutes / 43200, minutes / 1440, minutes / 60, minutes]

    %w(year month day hour minute).each_with_index do |type, i|
      q = quantity[i]
      if type == "minute" && q < 2
        return "just now"
      elsif q > 0
        return "#{q} #{type}#{ q == 1 ? "" : "s" } ago"
      end
    end
  end
end
