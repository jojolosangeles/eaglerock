require './config.rb'
require './csvloader.rb'
require 'yaml'

if (ARGV.length != 3) then
  print "Usage: ruby generateMapBounds.rb CITY_NAME CSV_Data_file location_variable"
end

cityName = ARGV[0]
csvDataFile = ARGV[1]
locationVariableName = ARGV[2]

config = Config.new()
foundCity = config.getCity(cityName)
if (foundCity == nil) then
  print "** FAILED to find city '#{cityName}'\n"
  exit
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

csvLoader = CsvLoader.new(csvDataFile)
locationSymbol = locationVariableName.to_sym
minLatitude = "999".to_f
maxLatitude = "-999".to_f
minLongitude = "999".to_f
maxLongitude = "-999".to_f
csvLoader.entries.each do |e|
  locationValue = e[locationSymbol]
  if ((locationValue != nil) && (locationValue != "")) then
    latitude,longitude,ok = config.extractLatitudeLongitude(locationValue)
    minLatitude = (latitude < minLatitude) ? latitude : minLatitude
    maxLatitude = (latitude > maxLatitude) ? latitude : maxLatitude
    minLongitude = (longitude < minLongitude) ? longitude : minLongitude
    maxLongitude = (longitude > maxLongitude) ? longitude : maxLongitude
  end
end

print "bounding_box:\n"
print "  upper_left:\n"
print "    latitude: #{minLatitude}\n"
print "    longitude: #{minLongitude}\n"
print "  lower_right:\n"
print "    latitude: #{maxLatitude}\n"
print "    longitude: #{maxLongitude}\n"