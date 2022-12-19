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
end
