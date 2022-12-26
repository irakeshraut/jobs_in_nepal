# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark do
  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:job) }
  end
end
