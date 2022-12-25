# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    password   { 'aaaaaaaa' }
    password_confirmation { 'aaaaaaaa' }
    email { Faker::Internet.email }

    trait :employer do
      role { 'employer' }
    end

    trait :job_seeker do
      role { 'job_seeker' }
    end

    trait :admin do
      role { 'admin' }
    end
  end
end
