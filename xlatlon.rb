lines = File.open(ARGV[0], "r")

def xdata(data, field, current)
  if (data[0] == field) then
    result = data[1].strip.split("\"")
    return "\"#{result[1]}\""
  else
    return current
  end
end

lat = lon = tooltip = ""
lines.each do |line|
  line.chomp!
  line.strip!
  data = line.split(":")
  lat = xdata(data, "\"lat\"", lat)
  lon = xdata(data, "\"lon\"", lon)
  tooltip = xdata(data, "\"tooltip\"", tooltip)
  if ((tooltip != "") && (tooltip != "\"\"")) then
    print "#{lat},#{lon},#{tooltip}\n"
    lat = lon = tooltip = ""
  end
end
