# frozen_string_literal: true

require 'rails_helper'

RSpec.describe View do
  let(:user) { create(:user, :admin) }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :ip }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:job) }
  end
end
