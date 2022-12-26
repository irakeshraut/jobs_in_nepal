# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord do
  let!(:user_today)      { create(:user, :admin) }
  let!(:user_this_week)  { create(:user, :admin) }
  let!(:user_this_month) { create(:user, :admin) }

  describe 'Scopes' do
    before do
      travel_to Time.zone.local(2022, 12, 12)
      user_today.update(created_at: Time.zone.now)
      user_this_week.update(created_at: Time.zone.now.end_of_week)
      user_this_month.update(created_at: Time.zone.now.end_of_month)
    end

    describe '.created_today' do
      it 'will return record created today' do
        expect(User.created_today).to match_array([user_today])
      end
    end

    describe '.created_this_week' do
      it 'will return record created this week' do
        expect(User.created_this_week).to match_array([user_today, user_this_week])
      end
    end

    describe '.created_this month' do
      it 'will return record created this month' do
        expect(User.created_this_month).to match_array([user_today, user_this_week, user_this_month])
      end
    end
  end
end
