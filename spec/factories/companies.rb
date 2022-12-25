# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name  { Faker::Company.name }
    phone { Faker::PhoneNumber.cell_phone }

    users { create(:user, :employer) }
  end
end
