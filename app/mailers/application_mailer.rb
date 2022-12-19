# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Jobs in Nepal <noreply@jobsinnepal.com>'
  layout 'mailer'
end
