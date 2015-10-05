class Address < ActiveRecord::Base
  enum result: { not_visited: 0, not_home: 1, not_interested: 2, interested: 3, unsure: 4 }

  acts_as_mappable :default_units => :meters,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

end
