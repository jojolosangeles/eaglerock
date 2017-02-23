class Config
  def valid_date?(date_string)
    m, d, y = date_string.split("/")
    if ((m != nil) && (d != nil) && (y != nil)) then
      return Date.valid_date? y.to_i, m.to_i, d.to_i
    end
    return false
  end

  def to_Date(date_string)
    return Date.strptime(date_string, '%m/%d/%Y')
  end
end