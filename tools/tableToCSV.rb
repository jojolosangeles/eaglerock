if (ARGV.length != 1) then
  print "Usage: ruby tableToCSV.rb <<HTML_File>>\n"
  exit
end

#
#  Assumptions:
#
#    <tr... starts a new row
#    </tr ... ends a row
#
#    <td... content is on this line, between 'td' tags, removing any additional tags
#
#        For the first row only, the content is free text that is transformed into a variable name
#
#            The transformation is:  lower case text, replace spaces with underscores
#
#        For every row after that, the content is the value of each variable
#

class ContentParser
  # What a line indicates to ContentParser
  IGNORE = "IGNORE"    # line doesn't contain any data
  NEW_ROW = "NEW_ROW"   # line indicates we are starting a new row of data
  NEW_CONTENT = "NEW_CONTENT"  # line contains a data value

  # What the content parser is expecting for the next line
  LOOKING_FOR_ROW_START =  100
  LOOKING_FOR_CONTENT_OR_ROW_END = 101

  # this value is returned for types IGNORE and NEW_ROW, since they don't have a value to share
  UNDEFINED_VALUE = "NO VALUE"

  attr_accessor :state

  def initialize()
    @state = LOOKING_FOR_ROW_START
  end

  #
  #  returns two values:
  #
  #    the type of content:  IGNORED, NEW_ROW, NEW_CONTENT
  #    the value of the content, with HTML tags stripped, only if type is NEW_CONTENT, otherwise value is UNDEFINED_VALUE
  #
  def getContent(line)
    line = line.strip
    if (line.length == 0) then
      return IGNORE,UNDEFINED_VALUE
    end
   # print "line: #{line}\n"
    if ((line.length > 3) && (line[0..2] == "<tr") && (@state == LOOKING_FOR_ROW_START)) then
      @state = LOOKING_FOR_CONTENT_OR_ROW_END
      return NEW_ROW,UNDEFINED_VALUE
    elsif ((line.length > 3) && (line[0..2] == "<td") && (@state == LOOKING_FOR_CONTENT_OR_ROW_END)) then
      return NEW_CONTENT,self.extractContent(line)
    elsif ((line.length > 4) && (line[0..3] == "</tr") && (@state == LOOKING_FOR_CONTENT_OR_ROW_END)) then
      @state = LOOKING_FOR_ROW_START
      return IGNORE,UNDEFINED_VALUE
    else
      return IGNORE,UNDEFINED_VALUE
    end
  end

  def extractContent(line)
    while (true) do
      line = line.strip
      gtOffset = line.index(">")
      if (gtOffset == nil) then
        return line
      end
      line = line[(gtOffset+1)..-1]
      line = line.reverse
      ltOffset = line.index("<")
      if (ltOffset == nil) then
        return line.reverse
      end
      line = line[(ltOffset+1)..-1]
      line = line.reverse
    end
  end
end

class CsvMaker
  # states
  #
  #   CONTENT_DEFINES_VARIABLE
  #   CONTENT_DEFINES_VALUE
  #
  CONTENT_DEFINES_VARIABLE = "content defines a variable name"
  CONTENT_DEFINES_VALUE = "content sets a value for a variable"

  attr_reader :variableNames, :csvLines

  def initialize()
    @variableNames = []
    @csvLines = []
    @valueList = []
    @state = CONTENT_DEFINES_VARIABLE
  end

  def process(content_type, content)
    #print "process #{content_type}, #{content}\n"
    if (content_type == ContentParser::NEW_ROW) then
      self.newRow()
    elsif (content_type == ContentParser::NEW_CONTENT) then
      if (@state == CONTENT_DEFINES_VARIABLE) then
        @variableNames << self.toVariableName(content)
      else
        @valueList << content
      end
    end
  end

  def toVariableName(s)
    s = s.downcase()
    s = s.strip()
    s = s.gsub(" ", "_")
    return s
  end

  def newRow()
    if (@variableNames.length > 0) then
      @state = CONTENT_DEFINES_VALUE
      if (@valueList.length == @variableNames.length) then
        @csvLines << @valueList
        @valueList = []
      elsif (@valueList.length > 0) then
        print "hmm... mismatched lengths #{@valueList.length}, #{@variableNames.length}\n"
      end
    end
  end
end

contentParser = ContentParser.new()
csvMaker = CsvMaker.new()
lines = File.open(ARGV[0], "r").readlines()
lines.each do |line|
  line.chomp!
  content_type,content = contentParser.getContent(line)
  if (content_type != ContentParser::IGNORE) then
    csvMaker.process(content_type,content)
  end
end

vars = csvMaker.variableNames
lines = csvMaker.csvLines
nvars = vars.length

lines.each do |csvLine|
  print "{"
  (0..(nvars - 1)).each do |i|
    print "," if (i > 0)
    print "\"#{vars[i]}\": \"#{csvLine[i]}\""
  end
  print "}\n"
end