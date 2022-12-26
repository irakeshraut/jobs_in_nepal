# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Applicant do
  let(:applicant) { build(:applicant) }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :resume_name }
    it { is_expected.to validate_inclusion_of(:status).in_array(Applicant::STATUS).allow_nil }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:job) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'STATUS' do
    it 'will return status array' do
      expect(described_class::STATUS).to match_array(%w[Shortlisted Rejected])
    end
  end

  describe '.shortlisted?' do
    context 'when applicant is shortlisted' do
      before { applicant.status = 'Shortlisted' }

      it 'will return true' do
        expect(applicant.shortlisted?).to be(true)
      end
    end

    context 'when applicant is not shorlisted' do
      it 'will return false' do
        expect(applicant.shortlisted?).to be(false)
      end
    end
  end

  describe '.rejected?' do
    context 'when applicant is rejected' do
      before { applicant.status = 'Rejected' }

      it 'will return true' do
        expect(applicant.rejected?).to be(true)
      end
    end

    context 'when applicant is not rejected' do
      it 'will return false' do
        expect(applicant.rejected?).to be(false)
      end
    end
  end
end
