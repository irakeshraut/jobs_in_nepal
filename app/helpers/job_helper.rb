module JobHelper
  def button_text
    if controller.action_name == "new"
       return "Post Job"
    elsif controller.action_name == "edit"
       return "Update Job"
    end
  end
end
