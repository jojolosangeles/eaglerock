require './csvloader.rb'
require './config.rb'
require "erb"

def usage()
  print "Usage: ruby generateMarkerInfo.rb <CSV File Path> \n"
  print "                                  <variable_containing_location> \n"
  print "                                  <MARKER Title ERB file> \n"
  print "                                  <issue date variable> <issue date minimum>\n"
end

if (ARGV.length != 5) then
  usage()
  exit
end

csvFilePath = ARGV[0]
variableContainingLocation = ARGV[1]
markerTitleErbFile = ARGV[2]
issueDateVariable = ARGV[3]
issueDateMinimum = ARGV[4]

config = Config.new()
if (!config.valid_date?(issueDateMinimum)) then
  usage()
  print "\nissue date minimum: #{issueDateMinimum} is invalid, expecting format MM/DD/YYYY\n"
  exit
end
issueMinimumDate = config.to_Date(issueDateMinimum)

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
  return issueDate > issueMinimumDate
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
symbolHoldingIssueDate = issueDateVariable.to_sym
titleErbString = File.read(markerTitleErbFile)

lineNumber = 0
csvLoader.entries.each do |entry|
  latitude,longitude = extractLatitudeLongitude(entry[symbolHoldingLocation])
  title = Basicerb.new(entry, titleErbString).render()
  date_string = entry[symbolHoldingIssueDate]
  if (!config.valid_date?(date_string)) then
    print "Line #{lineNumber} is invalid: #{date_string}, #{entry[symbolHoldingLocation]}\n"
  end
  lineNumber += 1
end

csvLoader.entries.each do |entry|
  latitude,longitude = extractLatitudeLongitude(entry[symbolHoldingLocation])
  title = Basicerb.new(entry, titleErbString).render()
  date_string = entry[symbolHoldingIssueDate]
  if (config.valid_date?(date_string) && dateOK(config.to_Date(date_string), issueMinimumDate) && (title.length > 3) && (latitude != 0) && (longitude != 0)) then
    print "#{latitude},#{longitude},#{date_string},#{title}\n"
  end
end
