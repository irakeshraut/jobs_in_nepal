module WorkExperiencesHelper
  def self.months
    %w(January February March April May June July August September October November December)
  end

  def self.years
    current_year = Time.new.year
    past_year = current_year - 20
    (past_year..current_year).to_a.reverse
  end
end
