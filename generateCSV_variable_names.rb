require './csvloader.rb'

if (ARGV.length != 1) then
  print "Usage: ruby generateCSV_variable_names.rb <csvFile>\n"
  print "\n\n  Outputs a sorted list of variable names\n"
  exit
end

csvFile = ARGV[0]
csvLoader = CsvLoader.new(csvFile)
keys = {}
csvLoader.entries.each do |e|
  e.keys.each do |key|
    keys[key] = 1
  end
end
keys.keys.sort.each do |key|
  print "#{key}\n"
end
