# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    title           { Faker::Job.title }
    description     { Faker::ChuckNorris.fact }
    category        { Category::LIST.keys.sample }
    location        { Faker::Address.city }
    employment_type { Job::TYPE.sample }
    status          { 'Active' }
    job_type        { Job::JOB_TYPE.values.sample }

    user { create(:user, :admin) }
  end
end
