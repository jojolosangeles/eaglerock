require './csvloader.rb'
require './config.rb'
require "erb"

def usage()
  print "Usage: ruby generateMarkerInfo.rb CSV_Data_file location_variable Map_Marker_Title_ERB_file date_variable date_minimum\n"
end

if (ARGV.length != 5) then
  usage()
  exit
end

csvFilePath = ARGV[0]
variableContainingLocation = ARGV[1]
markerTitleErbFile = ARGV[2]
dateVariableName = ARGV[3]
minimumDateBoundary = ARGV[4]

config = Config.new()
if (!config.valid_date?(minimumDateBoundary)) then
  usage()
  print "\nissue date minimum: #{minimumDateBoundary} is invalid, expecting format MM/DD/YYYY\n"
  exit
end
minimumDate = config.to_Date(minimumDateBoundary)

csvLoader = CsvLoader.new(csvFilePath)

class Basicerb
  def initialize(entry, templateString)
    @entry = entry
    @templateString = templateString
  end

  def render
    meTryingTemplate = ERB.new(@templateString).result( binding )
    return meTryingTemplate
  end
end

def monthDayOK(issueMonth, issueDay, minMonth, minDay)
  if (issueMonth > minMonth) then
    return true
  elsif (issueMonth == minMonth) then
    return issueDay >= minDay
  else
    return false
  end
end

def dateOK(issueDate, issueMinimumDate)
  return issueDate >= issueMinimumDate
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
    end
  end
  return latitude, longitude, ok
end

symbolHoldingLocation = variableContainingLocation.to_sym
symbolHoldingDate = dateVariableName.to_sym
titleErbString = File.read(markerTitleErbFile)

lineNumber = 0
csvLoader.entries.each do |entry|
  latitude,longitude = extractLatitudeLongitude(entry[symbolHoldingLocation])
  title = Basicerb.new(entry, titleErbString).render()
  date_string = entry[symbolHoldingDate]
  if (!config.valid_date?(date_string)) then
    print "Line #{lineNumber} is invalid: #{date_string}, #{entry[symbolHoldingLocation]}\n"
  end
  lineNumber += 1
end

csvLoader.entries.each do |entry|
  latitude,longitude = extractLatitudeLongitude(entry[symbolHoldingLocation])
  title = Basicerb.new(entry, titleErbString).render()
  date_string = entry[symbolHoldingDate]
  if (config.valid_date?(date_string) && dateOK(config.to_Date(date_string), minimumDate) && (title.length > 3) && (latitude != 0) && (longitude != 0)) then
    print "#{latitude},#{longitude},#{date_string},#{title}\n"
  end
end
