# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Education do
  let(:education)   { build(:education) }
  let(:finish_year) { 2.years.from_now.year }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :institution_name }
    it { is_expected.to validate_presence_of :course_name }
    it { is_expected.to validate_inclusion_of(:course_completed).in_array([true, false]) }
  end

  describe 'when course is completed' do
    context 'when finished year is present' do
      it 'will be valid' do
        expect(education).to be_valid
      end
    end

    context 'when finished year is not present' do
      before { education.finished_year = nil }

      it 'will be invalid' do
        expect(education).not_to be_valid
      end
    end
  end

  describe 'when course is not completed' do
    before do
      education.assign_attributes(course_completed: false, expected_finish_month: 12, expected_finish_year: finish_year)
    end

    context 'when expected finished month and year is present' do
      it 'will be valid' do
        expect(education).to be_valid
      end
    end

    context 'when expected finish month is not present' do
      before { education.expected_finish_month = nil }

      it 'will be invalid' do
        expect(education).not_to be_valid
      end
    end

    context 'when expected finish year is not present' do
      before { education.expected_finish_year = nil }

      it 'will be invalid' do
        expect(education).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Rich Text' do
    it { is_expected.to have_rich_text(:course_highlights) }
  end

  describe '#clean_up_course_finish_time' do
    context 'when course is completed' do
      before do
        education.assign_attributes(expected_finish_month: 11, expected_finish_year: finish_year)
        education.save
      end

      it 'will set expected finished month to nil' do
        expect(education.expected_finish_month).to be_nil
      end

      it 'will set expected finished year to nil' do
        expect(education.expected_finish_year).to be_nil
      end
    end

    context 'when course is not completed' do
      let(:education) { build(:education, :not_completed, finished_year: 2021) }

      before { education.save }

      it 'will set finished year to nil' do
        expect(education.finished_year).to be_nil
      end
    end
  end

  # TODO: write spec for delete_empty_course_highlights
end
