class Address < ActiveRecord::Base
  enum latest_result: {
    not_visited: 'Not visited',
    not_home: 'Not home',
    not_interested: 'Not interested',
    interested: 'Interested',
    unsure: 'Not sure'
  }

  acts_as_mappable :default_units => :meters,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

end
