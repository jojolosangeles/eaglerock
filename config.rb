require 'yaml'

class Config
  def initialize()
    @cities = YAML.load(File.open("config/cities.cfg"))
  end

  def getCity(cityName)
    foundCity = nil
    @cities.each do |city|
      if (city["name"] == cityName) then
        foundCity = city
        break
      end
    end
    return foundCity
  end

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

  def extractLatitudeLongitude(llStr)
    # expecting format "(lat, long)"
    ok = false
    latitude = longitude = 0
    if ((llStr != nil) && (llStr.length > 3)) then
      llStr = llStr[1..-2]
      data = llStr.split(",")
      if (data.length == 2) then
        latitude = data[0].strip
        longitude = data[1].strip
        ok = true
      end
    end
    return latitude.to_f, longitude.to_f, ok
  end
end