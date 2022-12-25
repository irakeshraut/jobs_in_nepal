# frozen_string_literal: true

module DateHelper
  def months
    { 'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6, 'July' => 7, 'August' => 8,
      'September' => 9, 'October' => 10, 'November' => 11, 'December' => 12 }
  end

  def years_in_past
    current_year = Time.zone.now.year
    past_year = current_year - 20
    (past_year..current_year).to_a.reverse
  end

  def years_in_future
    current_year = Time.zone.now.year
    future_year = current_year + 20
    (current_year..future_year).to_a
  end
end
