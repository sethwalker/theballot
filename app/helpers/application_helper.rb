# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_error_messages(object_name)
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      content_tag("div",
      object.errors.full_messages.collect { |msg| content_tag("div", msg, "class" => "errorExplanation") })
    else
      ""
    end
  end
end
