class EmployerMailer < ApplicationMailer
  def application_submitted(company_user, job, applicant_user)
    @company_user = company_user
    @job  = job
    @applicant_user = applicant_user
    mail(to: user.email, subject: "You have new job applicant")
  end
end
