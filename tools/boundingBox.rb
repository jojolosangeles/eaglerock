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
end