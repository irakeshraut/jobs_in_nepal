# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkExperience do
  let(:work_experience) { build(:work_experience) }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :job_title }
    it { is_expected.to validate_presence_of :company_name }
    it { is_expected.to validate_presence_of(:start_month) }
    it { is_expected.to validate_presence_of(:start_year) }
    it { is_expected.to validate_inclusion_of(:still_in_role).in_array([true, false]) }
  end

  describe 'when user is still in current role' do
    let(:work_experience) { build(:work_experience, :finished) }

    context 'when expected finished month and year is present' do
      it 'will be valid' do
        expect(work_experience).to be_valid
      end
    end

    context 'when finish month is not present' do
      before { work_experience.finish_month = nil }

      it 'will be invalid' do
        expect(work_experience).not_to be_valid
      end
    end

    context 'when finish year is not present' do
      before { work_experience.finish_year = nil }

      it 'will be invalid' do
        expect(work_experience).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Rich Text' do
    it { is_expected.to have_rich_text(:description) }
  end

  describe 'Before Save Callback' do
    before { allow(work_experience).to receive(:clean_up_work_experience_finish_time) }

    it 'will call clean_up_work_experience_finish_time method' do
      work_experience.save
      expect(work_experience).to have_received(:clean_up_work_experience_finish_time)
    end
  end

  describe '#clean_up_work_experience_finish_time' do
    context 'when user is still in role' do
      it 'will set finished year to nil' do
        expect(work_experience.clean_up_work_experience_finish_time).to be_nil
      end
    end

    context 'when user is not in role' do
      before do
        work_experience.assign_attributes(finish_month: 11, finish_year: 2.years.ago.year)
        work_experience.save
      end

      it 'will set expected finished month to nil' do
        expect(work_experience.finish_month).to be_nil
      end

      it 'will set expected finished year to nil' do
        expect(work_experience.finish_year).to be_nil
      end
    end
  end

  # TODO: write spec for delete_empty_description
end
