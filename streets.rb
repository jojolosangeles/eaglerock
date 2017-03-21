require 'erb'
require './config.rb'

if (ARGV.length != 3) then
  print "Usage: ruby streets.rb <city> <number of latitude values> <number of longitude values>\n"
  exit
end

class SimpleErb
  def initialize(templateString, latVal, lonVal, city, nLat, nLon)
    @latVal = latVal
    @lonVal = lonVal
    @key = "#{city}_#{nLat}x#{nLon}"
    @templateString = templateString
  end

  def render
    return ERB.new(@templateString).result( binding )
  end
end
cityName = ARGV[0]
numberLatitudes = ARGV[1].to_i
numberLongitudes = ARGV[2].to_i

config = Config.new()
city = config.getCity(cityName)
boundingBox = BoundingBox.new(city)

curlTemplateString = File.open("templates/streets_geonames.erb").read

nLat = 0
nLon = 0
city = city["variable_name"]

print "set -x\n"
boundingBox.latSections(numberLatitudes) do |latVal|
  nLon = 0
  boundingBox.lonSections(numberLongitudes) do |lonVal|
    curlCmd = SimpleErb.new(curlTemplateString, latVal, lonVal, city, nLat, nLon)
    print "#{curlCmd.render()}\n"
    print "sleep 1\n"
    nLon += 1
  end
  nLat += 1
end
