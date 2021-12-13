class View < ApplicationRecord
  validates :ip, presence: true
  validates :ip, uniqueness: { scope: :job_id }
  belongs_to :job
end
