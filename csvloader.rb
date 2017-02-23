require 'smarter_csv'

class CsvLoader
  attr_reader :entries

  def initialize(filePath)
    data = SmarterCSV.process(filePath)
    @entries = data
  end
end
      
