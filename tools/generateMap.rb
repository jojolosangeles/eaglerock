require 'yaml'

if (ARGV.length != 1) then
  print "Usage: ruby generateMap.rb MAP_CONFIGURATION_NAME\n"
  exit
end

mapConfigurationName = ARGV[0]

class MapConfig
  attr_reader :configurations

  def initialize(configFile)
    @configurations = YAML.load(File.open(configFile))
  end

  def getConfiguration(name)
    @configurations.each do |configuration|
      if (configuration["name"] == name) then
        return configuration
      end
    end
    return nil
  end
end

#- name: Eagle Rock
#
# 'configuration' has YAML structure for "Eagle Rock"
#
maps = MapConfig.new("config/maps.cfg")
configuration = maps.getConfiguration(mapConfigurationName)
if (configuration == nil) then
  print "** FAILED **, configuration named '#{mapConfigurationName}' NOT found in config/maps.cfg\n"
  exit
end

#  boundary_name: Eagle Rock
#
#  Load cities configuration, set data boundary based on Eagle Rock
#
# 'boundingBox' has map boundaries for data we show
#
config = Config.new()
city = config.getCity(cityName)
boundingBox = BoundingBox.new(city)

#  data_source_file: data/Building_and_Safety_Permit_Information.csv
#  latitude_longitude_variable: latitude_longitude "(lat,lng)"
#  filtered_data_file: working/Building_and_Safety_Permit_Information.eagle_rock.csv
#
#  Process data file, get rid of any lines that don't fall within the bounding box
#
#  When done, the 'filtered_data_file' has been created
#
data_source_file = configuration["data_source_file"]
filtered_data_file = configuration["filtered_data_file"]
latitude_longitude_variable, latitude_longitude_format = configuration["latitude_longitude_variable"].split
latitude_longitude_symbol = latitude_longitude_variable.to_sym()

lines = File.open(data_source_file, "r").readlines
csvLoader = CsvLoader.new(data_source_file)
filteredDataFile = File.open(filtered_data_file, "w")
filteredDataFile.print(lines[0])  # header line
lineNumber = 1
csvLoader.entries.each do |entry|
  latitude,longitude,ok = config.extractLatitudeLongitude(entry[latitude_longitude_symbol])
  filteredDataFile.print "#{lines[lineNumber]}" if (ok && boundingBox.includes(latitude,longitude))
  lineNumber += 1
end
filteredDataFile.close()

#  marker_text_variable: work_description
#  map_template: templates/Building_and_Safety_Permit_Information.erb

