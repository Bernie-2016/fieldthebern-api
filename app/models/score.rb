class Score < ActiveRecord::Base
  belongs_to :visit

  def total_points
    points_for_updates + points_for_knock
  end
end
