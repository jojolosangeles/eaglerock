require 'erb'

if ((ARGV.length != 2) || (ENV["GOOGLE_MAP_KEY"] == nil)) then
  print "Usage: ruby generateHTML.rb <ERB template> <marker info>\n"
  print "\n       Environment variable GOOGLE_MAP_KEY must be defined\n"
  exit
end

class Basicerb2
  def initialize(entry, google_map_key, templateString)
    @mapItems = entry
    @google_map_key = google_map_key
    @templateString = templateString
  end

  def render
    meTryingTemplate = ERB.new(@templateString).result( binding )
    return meTryingTemplate
  end
end

erbTemplateFile = ARGV[0]
markerInfoFile = ARGV[1]

class Item
  attr_reader :lat, :lng, :text
  def initialize(lat, lng, text)
    @lat = lat
    @lng = lng
    @text = text
  end
end

# http://stackoverflow.com/questions/770523/escaping-strings-in-javascript
def addSlashes(s)
  return s.gsub("\"", "\\\"")
end

def stripTime(s)
  data = s.split
  return data[0]
end

@mapItems = []
lines = File.open(markerInfoFile, "r").readlines
lines.each do |line|
  line.chomp!
  data = line.split(",", 4)
  @mapItems << Item.new(data[0], data[1], "#{stripTime(data[2])}, #{addSlashes(data[3])}")
end

erbTemplate = File.open(erbTemplateFile).read

basicErb = Basicerb2.new(@mapItems, ENV["GOOGLE_MAP_KEY"], erbTemplate)
print basicErb.render()

