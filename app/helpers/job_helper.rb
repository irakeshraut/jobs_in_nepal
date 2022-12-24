# frozen_string_literal: true

module JobHelper
  def button_text
    case controller.action_name
    when 'new'
      'Post Job'
    when 'edit'
      'Update Job'
    end
  end

  def salary(job)
    min_salary = job.min_salary
    max_salary = job.max_salary

    return 'Salary Not Mentioned' if min_salary.blank? && max_salary.blank?
    return formatted_salary(min_salary, max_salary) if min_salary.present? && max_salary.present?

    salary_without_zero(min_salary.presence || max_salary.presence)
  end

  # NOTE: Below methods are just helpers method, can't make them private since its module
  def salary_without_zero(salary)
    number_to_currency(salary)&.gsub(/\.00$/, '')
  end

  def formatted_salary(min_salary, max_salary)
    "#{salary_without_zero(min_salary)} - #{salary_without_zero(max_salary)}"
  end
end
