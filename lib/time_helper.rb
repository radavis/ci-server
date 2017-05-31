module TimeHelper
  def now
    Time.new.to_i
  end

  def time_ago(seconds, now = Time.now.to_i)
    delta = now - seconds
    minutes = delta / 60
    return "just now" if minutes < 2

    quantity = [minutes / 525600, minutes / 43200, minutes / 1440, minutes / 60, minutes]
    type = %w(years months days hours mintues)

    # get the first non-zero index from quantity
    index = nil
    quantity.each_with_index { |q, i| index = i if q > 0 && !index }

    "#{quantity[index]} #{type[index]} ago"
  end
end
