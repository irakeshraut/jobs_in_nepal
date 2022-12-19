# frozen_string_literal: true

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

candidate_one = User.find_by(email: 'candidate1@test.com')
if candidate_one.nil?
  User.create(first_name: 'Candidate', last_name: 'One', role: 'job_seeker', email: 'candidate1@test.com',
              password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

candidate_two = User.find_by(email: 'candidate2@test.com')
if candidate_two.nil?
  User.create(first_name: 'Candidate', last_name: 'Two', role: 'job_seeker', email: 'candidate2@test.com',
              password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

candidate_three = User.find_by(email: 'candidate3@test.com')
if candidate_three.nil?
  User.create(first_name: 'Candidate', last_name: 'Three', role: 'job_seeker', email: 'candidate3@test.com',
              password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
end

#######################################
#         Admin
#######################################

admin = User.find_by(email: 'admin@test.com')
if admin.nil?
  User.create(first_name: 'Admin', last_name: 'One', role: 'admin', email: 'admin@test.com', password: 'aaaaaaaa',
              password_confirmation: 'aaaaaaaa')
end

#######################################
#         Companies
#######################################

company_one   = Company.find_or_create_by(name: 'Company 1', phone: '0000000000')
company_two   = Company.find_or_create_by(name: 'Company 2', phone: '0000000000')
company_three = Company.find_or_create_by(name: 'Company 3', phone: '0000000000')

#######################################
#         Employers
#######################################
employer = User.find_by(email: 'employer1@test.com')
employer_one = if employer.nil?
                 User.create(first_name: 'Employer', last_name: 'One', role: 'employer', email: 'employer1@test.com',
                             password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
               else
                 employer
               end
employer = User.find_by(email: 'employer2@test.com')
employer_two = if employer.nil?
                 User.create(first_name: 'Employer', last_name: 'Two', role: 'employer', email: 'employer2@test.com',
                             password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
               else
                 employer
               end
employer = User.find_by(email: 'employer3@test.com')
employer_three = if employer.nil?
                   User.create(first_name: 'Employer', last_name: 'Three', role: 'employer',
                               email: 'employer3@test.com', password: 'aaaaaaaa', password_confirmation: 'aaaaaaaa')
                 else
                   employer
                 end

#######################################
#    Assign Employer to Compnay
#######################################
company_one.users << employer_one unless company_one.users.include?(employer_one)
company_two.users << employer_two unless company_two.users.include?(employer_two)
company_three.users << employer_three unless company_three.users.include?(employer_three)

#########################################
#   Activate User
########################################

User.all.each(&:activate!)
