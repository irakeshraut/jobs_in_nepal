# frozen_string_literal: true

FactoryBot.define do
  factory :education do
    institution_name { Faker::Lorem.words(number: 3) }
    course_name      { Faker::Lorem.words(number: 3) }
    course_completed { true }
    finished_year    { 3.years.ago }

    user { create(:user, :job_seeker) }

    trait :not_completed do
      course_completed { false }
      expected_finish_month { (1..12).to_a.sample }
      expected_finish_year  { 2.years.from_now.year }
    end
  end
end
