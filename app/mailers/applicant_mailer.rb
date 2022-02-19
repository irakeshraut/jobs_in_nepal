class ApplicantMailer < ApplicationMailer
  def application_viewed(user, job, applicant)
    @user = user
    @job  = job
    @applicant = applicant
    mail(to: user.email, subject: "Your application has been viewed")
  end
end
