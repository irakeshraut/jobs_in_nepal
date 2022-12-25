# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job do
  let(:job) { build(:job) }

  describe 'Validation' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :category }
    it { is_expected.to validate_presence_of :location }
    it { is_expected.to validate_presence_of :employment_type }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :job_type }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:applicants).dependent(:destroy) }
    it { is_expected.to have_many(:views).dependent(:destroy) }
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:applicants) }
  end

  describe 'Rich Text' do
    it { is_expected.to have_rich_text(:description) }
    it { is_expected.to validate_presence_of(:description) }
  end

  # TODO: finish other scopes
  describe 'Scopes' do
    let!(:active)  { create(:job) }
    let!(:closed)  { create(:job, status: 'Closed') }
    let!(:expired) { create(:job, status: 'Expired') }

    describe '.active' do
      it 'will return active jobs' do
        expect(described_class.active).to eq([active])
      end
    end

    describe '.closed' do
      it 'will return closed jobs' do
        expect(described_class.closed).to eq([closed])
      end
    end

    describe '.expired' do
      it 'will return expired jobs' do
        expect(described_class.expired).to eq([expired])
      end
    end

    # TODO: finish other scopes
  end

  describe '#active?' do
    context 'when job is active' do
      it 'will return true' do
        expect(job.active?).to be(true)
      end
    end

    context 'when job is not active' do
      before { job.status = 'Expired' }

      it 'will return false' do
        expect(job.active?).to be(false)
      end
    end
  end

  describe '#expired?' do
    context 'when job is expired' do
      before { job.status = 'Expired' }

      it 'will return true' do
        expect(job.expired?).to be(true)
      end
    end

    context 'when job is not expired' do
      it 'will return false' do
        expect(job.expired?).to be(false)
      end
    end
  end

  describe '#closed?' do
    context 'when job is closed' do
      before { job.status = 'Closed' }

      it 'will return true' do
        expect(job.closed?).to be(true)
      end
    end

    context 'when job is not closed' do
      it 'will return false' do
        expect(job.closed?).to be(false)
      end
    end
  end

  describe '#created_by_admin?' do
    context 'when created by admin' do
      it 'will return true' do
        expect(job.created_by_admin?).to be(true)
      end
    end

    context 'when not created by admin' do
      before { job.user.role = 'employer' }

      it 'will return false' do
        expect(job.created_by_admin?).to be(false)
      end
    end
  end

  describe '#created_by_employer?' do
    context 'when created by employer' do
      before { job.user.role = 'employer' }

      it 'will return true' do
        expect(job.created_by_employer?).to be(true)
      end
    end

    context 'when not created by employer' do
      it 'will return false' do
        expect(job.created_by_employer?).to be(false)
      end
    end
  end

  describe '#similar_jobs' do
    let(:job)  { create(:job, title: 'Foo Bar', category: 'Legal') }
    let(:job1) { create(:job, title: 'Qax Foo Bar Baz', category: 'Others') }
    let(:job2) { create(:job, title: 'Baz', category: 'Legal') }
    let(:job3) { create(:job, title: 'Qax', category: 'Sales') }

    it 'will return similar jobs' do
      expect(job.similar_jobs).to match_array([job1, job2])
    end

    it 'will not include job that dont match condition' do
      expect(job.similar_jobs).not_to include(job3)
    end
  end
end
