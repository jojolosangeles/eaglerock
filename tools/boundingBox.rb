class BoundingBox
  def initialize(city)
    bounding_box = city["bounding_box"]
    @minLatitude = bounding_box["min_latitude"].to_f
    @maxLatitude = bounding_box["max_latitude"].to_f
    @minLongitude = bounding_box["min_longitude"].to_f
    @maxLongitude = bounding_box["max_longitude"].to_f
  end

  def includes(latitude, longitude)
    return (latitude >= @minLatitude) &&
           (latitude <= @maxLatitude) &&
           (longitude >= @minLongitude) &&
           (longitude <= @maxLongitude)
  end

  def latSections(n, &blockForFuckOfIt)
    incSize = (@maxLatitude - @minLatitude)/(n-1)  # if we have 10 locations, there are 9 internal boundaries
    return sectionIterator(@minLatitude, incSize, n, &blockForFuckOfIt)
  end

  def lonSections(n, &blockForFuckOfIt)
    incSize = (@maxLongitude - @minLongitude)/(n-1)  # if we have 10 locations, there are 9 internal boundaries
    return sectionIterator(@minLongitude, incSize, n, &blockForFuckOfIt)
  end

  def sectionIterator(start, incSize, n, &blockForFuckOfIt)
    locations = []
    locations << start
    (1..(n-1)).each do |offset|
      locations << (start + offset*incSize)
    end

    (0..(n-1)).each do |offset|
      yield locations[offset], blockForFuckOfIt
    end
  end

end