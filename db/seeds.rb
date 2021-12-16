# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#######################################
#         Candidates/Job Seekers
#######################################

candidate_1 = User.find_by(email: 'candidate1@test.com')
if candidate_1.nil?
  User.create(first_name: 'Candidate', last_name: 'One', role: 'job_seeker', email: 'candidate1@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

candidate_2 = User.find_by(email: 'candidate2@test.com')
if candidate_2.nil?
  User.create(first_name: 'Candidate', last_name: 'Two', role: 'job_seeker', email: 'candidate2@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

candidate_3 = User.find_by(email: 'candidate3@test.com')
if candidate_3.nil?
  User.create(first_name: 'Candidate', last_name: 'Three', role: 'job_seeker', email: 'candidate3@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

#######################################
#         Admin
#######################################

admin = User.find_by(email: 'admin@test.com')
if admin.nil?
  User.create(first_name: 'Admin', last_name: 'One', role: 'admin', email: 'admin@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

#######################################
#         Companies
#######################################

company_1 = Company.find_or_create_by(name: 'Company 1', phone: '0000000000' )
company_2 = Company.find_or_create_by(name: 'Company 2', phone: '0000000000' )
company_3 = Company.find_or_create_by(name: 'Company 3', phone: '0000000000' )

#######################################
#         Employers
#######################################
employer_1, employer_2, employer_3 = nil
employer = User.find_by(email: 'employer1@test.com')
if employer.nil?
  employer_1 = User.create(first_name: 'Employer', last_name: 'One', role: 'employer', email: 'employer1@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
else
  employer_1 = employer
end
employer = User.find_by(email: 'employer2@test.com')
if employer.nil?
  employer_2 = User.create(first_name: 'Employer', last_name: 'Two', role: 'employer', email: 'employer2@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
else
  employer_2 = employer
end
employer = User.find_by(email: 'employer3@test.com')
if employer.nil?
  employer_3 = User.create(first_name: 'Employer', last_name: 'Three', role: 'employer', email: 'employer3@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
else
  employer_3 = employer
end

#######################################
#    Assign Employer to Compnay 
#######################################
unless company_1.users.include?(employer_1)
  company_1.users << employer_1
end
unless company_2.users.include?(employer_2)
  company_2.users << employer_2
end
unless company_3.users.include?(employer_3)
  company_3.users << employer_3
end
