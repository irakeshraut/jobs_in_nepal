# frozen_string_literal: true

FactoryBot.define do
  factory :work_experience do
    job_title     { Faker::Job.title }
    company_name  { Faker::Company.name }
    start_month   { (1..12).to_a.sample }
    start_year    { 2.years.ago }
    still_in_role { true }

    user { create(:user, :job_seeker) }

    trait :finished do
      still_in_role { false }
      finish_month  { (1..12).to_a.sample }
      finish_year   { 1.year.ago.year }
    end
  end
end
