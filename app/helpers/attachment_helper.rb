# frozen_string_literal: true

module AttachmentHelper
  def filename_with_date(attachment)
    filename, timestamp = attachment.filename.to_s.split('-')
    "#{filename} - #{formatted_date(timestamp)}"
  end

  def filenames_with_date(attachments)
    attachments.map { |attachment| [filename_with_date(attachment), attachment.filename] }
  end

  # These are helpers not uses anywhere. Can't make module private

  def formatted_date(timestamp)
    Time.zone.at(timestamp.to_i).strftime('%m/%d/%Y')
  end
end
