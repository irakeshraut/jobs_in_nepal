# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user, :admin) }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    # it { is_expected.to validate_presence_of :password }
    # it { is_expected.to validate_presence_of :password_confirmation }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :role }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:company).optional }
    it { is_expected.to have_many(:jobs).dependent(:destroy) }
    it { is_expected.to have_many(:work_experiences).dependent(:destroy) }
    it { is_expected.to have_many(:educations).dependent(:destroy) }
    it { is_expected.to have_many(:applicants).dependent(:destroy) }
    it { is_expected.to have_many(:applied_jobs).through(:applicants) }
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
  end

  describe 'Nested Attributes' do
    it { is_expected.to accept_nested_attributes_for(:work_experiences).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:educations).allow_destroy(true) }
  end

  # TODO: test dependent destroy, shoulda matcher don't have this helper for attachment, may write own reflexation
  describe 'Attachments' do
    it { is_expected.to have_many_attached(:resumes) }
    it { is_expected.to have_many_attached(:cover_letters) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  # TODO: finish other scopes
  describe 'Scopes' do
    let!(:rakesh) { create(:user, :admin, first_name: 'Rakesh', last_name: 'Raut') }
    let!(:rajina) { create(:user, :admin, first_name: 'Rajina', last_name: 'Raut') }

    describe '.filter_by_name' do
      it 'will return users with first name "Rakesh"' do
        expect(described_class.filter_by_name('rakesh')).to eq([rakesh])
      end

      it 'will return users with last name "Raut"' do
        expect(described_class.filter_by_name('Raut')).to eq([rakesh, rajina])
      end
    end
  end

  describe '#admin?' do
    context 'when admin' do
      it 'will return true' do
        expect(user.admin?).to be(true)
      end
    end

    context 'when not a admin' do
      before { user.role = 'employer' }

      it 'will return false' do
        expect(user.admin?).to be(false)
      end
    end
  end

  describe '#employer?' do
    context 'when employer' do
      before { user.role = 'employer' }

      it 'will return true' do
        expect(user.employer?).to be(true)
      end
    end

    context 'when not a employer' do
      it 'will return false' do
        expect(user.employer?).to be(false)
      end
    end
  end

  describe '#job_seeker?' do
    context 'when job seeker' do
      before { user.role = 'job_seeker' }

      it 'will return true' do
        expect(user.job_seeker?).to be(true)
      end
    end

    context 'when not a employer' do
      it 'will return false' do
        expect(user.job_seeker?).to be(false)
      end
    end
  end

  describe '#full_name' do
    it 'will return full name' do
      expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
    end
  end
end
