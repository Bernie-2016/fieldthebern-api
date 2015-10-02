class Address < ActiveRecord::Base
  enum result: { not_visited: 0, not_home: 1, not_interested: 2, interested: 3 }

  scope :within, -> (longitude, latitude, radius) {
    factory = RGeo::Geographic.spherical_factory
    center = factory.point(longitude, latitude)
    where("ST_DWITHIN(coordinates, ST_MakePoint(?, ?), ?)", longitude, latitude, radius)
  }
end
