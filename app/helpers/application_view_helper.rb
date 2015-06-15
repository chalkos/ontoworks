module ApplicationViewHelper
  #http://stackoverflow.com/a/7756320
  def nav_link(link_text, link_path, id_def=nil, method_def=nil)
    class_name = current_page?(link_path) ? 'active' : nil

    content_tag(:li, :class => class_name, :id => id_def) do
      link_to link_text, link_path, method: method_def
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

  # if str.length < maxlen returns the string itself
  # else returns a string beginning and ending as the
  # original but having (...) in the middle and a maximum length of maxlen
  def reduce_string(str, maxlen, middle='[...]')
    return str if str.length <= maxlen

    maxlen -= middle.length
    str[0...(maxlen/2)] + middle + str[(str.length-(maxlen/2)-(maxlen%2))...str.length]
  end
end
