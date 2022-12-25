# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  describe 'Validation' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_size_of(:logo).less_than(2.megabytes) }
    it { is_expected.to validate_content_type_of(:logo).allowing('image/png', 'image/jpg', 'image/jpeg') }
  end

  describe 'Association' do
    it { is_expected.to have_many(:users).dependent(:destroy) }
  end

  describe 'Nested Attributes' do
    it { is_expected.to accept_nested_attributes_for(:users) }
  end

  describe 'Rich Text' do
    it { is_expected.to have_rich_text(:description) }
  end

  # TODO: write spec for delete_empty_description
end
