# frozen_string_literal: true

FactoryBot.define do
  factory :applicant do
    resume_name { Faker::Lorem.word }

    job  { create(:job) }
    user { create(:user, :job_seeker) }

    trait :not_completed do
      course_completed { false }
      expected_finish_month { (1..12).to_a.sample }
      expected_finish_year  { 2.years.from_now.year }
    end
  end
end
