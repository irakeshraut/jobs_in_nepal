# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def application_submitted(company_user, job, applicant_user)
    @company_user = company_user
    @job = job
    @applicant_user = applicant_user
    mail(to: @company_user.email, subject: 'You have new job applicant')
  end
end
