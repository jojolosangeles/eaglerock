require 'date'

debug = (ARGV.length == 1) && (ARGV[0] == "debug")

class AcceptableDateFolder
  attr_reader :folderName

  def initialize(folderName, todayDate)
    @folderName = folderName
    @todayDate = todayDate
    @folderExists = Dir.exists?(folderName)
    @folderCreateDate = File.ctime(folderName) if (@folderExists)
  end

  def isValid?()
    return (@folderExists &&
            (@folderCreateDate.year == @todayDate.year) &&
            (@folderCreateDate.month == @todayDate.month) &&
            (@folderCreateDate.day == @todayDate.day))
  end

  def exists()
    return @folderExists
  end

end

todayDate = Date.today()
workingFolder = AcceptableDateFolder.new("working", todayDate)
todayFolder = AcceptableDateFolder.new("today", todayDate)

print "rm -rf results\n"
print "rm -rf #{workingFolder.folderName}\n" if (!workingFolder.isValid?())
print "rm -rf #{todayFolder.folderName}\n" if (!todayFolder.isValid?())
print "mv working today\n" if (workingFolder.isValid?() && !todayFolder.isValid?())
print "rm -rf working\n" if (workingFolder.isValid?() && todayFolder.isValid?())

# at this point, there is NO working directory, create it
print "mkdir working\n"
print "mkdir results\n"

class FileDependency
  attr_accessor :debug

  def initialize(environmentVariable, baseFile, derivedFolder, derivedFileExtensions)
    @environmentVariable = environmentVariable
    @baseFile = baseFile
    @derivedFolder = derivedFolder
    @derivedFileExtensions = derivedFileExtensions
    @debug = false
  end

  def derivedFolderExists()
    return Dir.exists?(@derivedFolder)
  end

  def derivedFilesExist()
    @derivedFileExtensions.each do |fileExtension|
      fileName = "#{@derivedFolder}/#{@baseFile}.#{fileExtension}"
      print "checking for #{fileName}\n" if (@debug)
      if (!File.exists?(fileName)) then
        return false
      end
    end
    return true
  end

  def derivedDatesAcceptable()
    baseDate = File.ctime("data/#{@baseFile}.csv")
    @derivedFileExtensions.each do |fileExtension|
      derivedDate = File.ctime("#{@derivedFolder}/#{@baseFile}.#{fileExtension}")
      if (derivedDate < baseDate) then
        return false
      end
    end
    return true
  end

  def genScript()
    print "unset #{@environmentVariable}\n"
    if (self.derivedFolderExists() &&
        self.derivedFilesExist() &&
        self.derivedDatesAcceptable()) then
        print "export #{@environmentVariable}=1\n"
    else
      print "derivedFolderExists()=#{self.derivedFolderExists()}\n" if (@debug)
      print "derivedFilesExist()=#{self.derivedFilesExist()}\n" if (@debug)
      print "derivedDatesAcceptable()=#{self.derivedDatesAcceptable()}\n" if (@debug)
    end
  end
end

permitFiles = FileDependency.new("SKIP_PERMITS",
                                 "Building_and_Safety_Permit_Information",
                                 "today",
                                 [ "3_lines", "variable_names" ])
#permitFiles.debug = true
print "# Permits script\n"
permitFiles.genScript()

crimeFiles = FileDependency.new("SKIP_CRIMES",
                                 "LAPD_Crime_and_Collision_Raw_Data_for_2016",
                                 "today",
                                 [ "3_lines", "variable_names" ])
print "# Crimes script\n"
crimeFiles.genScript()

print "# all done\n"