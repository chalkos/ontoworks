module ApplicationViewHelper
  #http://stackoverflow.com/a/7756320
  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : nil

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  # obtains the error messages for any used model
  def error_messages
    [@ontology, @user, @query]
      .keep_if( &:present? )
      .map(&:errors)
      .map(&:full_messages)
      .flatten
  end
end
