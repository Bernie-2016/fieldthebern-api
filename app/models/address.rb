class Address < ActiveRecord::Base
  enum result: { not_visited: 0, not_home: 1, not_interested: 2, interested: 3 }

  scope :within, -> (sw_lon, sw_lat, ne_lon, ne_lat) {
    factory = RGeo::Geographic.spherical_factory
    sw = factory.point(sw_lon, sw_lat)
    ne = factory.point(ne_lon, ne_lat)
    window = RGeo::Cartesian::BoundingBox.create_from_points(sw, ne).to_geometry
    where("coordinates && ?", window)
  }
end
