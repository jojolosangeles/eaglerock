require './csvloader.rb'
require './config.rb'

if (ARGV.length != 3) then
  print "Usage: ruby filterLocationByCity.rb CITY_NAME CSV_Data_file location_variable\n"
  exit
end

cityName = ARGV[0]
csvDataFile = ARGV[1]
locationVariableName = ARGV[2]
locationSymbol = locationVariableName.to_sym()

config = Config.new()
city = config.getCity(cityName)
bounding_box = city["bounding_box"]
#print "#{bounding_box}\n"
minLatitude = bounding_box["min_latitude"]
maxLatitude = bounding_box["max_latitude"]
minLongitude = bounding_box["min_longitude"]
maxLongitude = bounding_box["max_longitude"]
lines = File.open(csvDataFile, "r").readlines
csvLoader = CsvLoader.new(csvDataFile)

#print "File has #{lines.length} lines, csvLoader has #{csvLoader.entries.length} entries\n"
lineNumber = 1
csvLoader.entries.each do |entry|
  latitude,longitude,ok = config.extractLatitudeLongitude(entry[locationSymbol])
  result = ok & (latitude >= minLatitude) && (latitude <= maxLatitude) && (longitude >= minLongitude) &&(longitude <= maxLongitude)
  #print "#{latitude},#{longitude} within #{minLatitude}-#{maxLatitude} and #{minLongitude}-#{maxLongitude}? #{result}\n"
  print "#{lines[lineNumber]}" if (result)
  lineNumber += 1
end