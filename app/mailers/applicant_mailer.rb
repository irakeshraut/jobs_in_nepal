# frozen_string_literal: true

class ApplicantMailer < ApplicationMailer
  def application_submitted(user, job, applicant)
    @user = user
    @job  = job
    @applicant = applicant
    mail(to: user.email, subject: 'Your application was successfully submitted')
  end

  def application_viewed(user, job, applicant)
    @user = user
    @job  = job
    @applicant = applicant
    mail(to: user.email, subject: 'Your application has been viewed')
  end

  def application_rejected(job, applicant)
    @user = applicant.user
    @job = job
    @applicant = applicant
    mail(to: @user.email, subject: "Application update for #{@job.title}")
  end
end
