# frozen_string_literal: true

module HtmlEscape
  module_function

  def h(value)
    ERB::Util.html_escape(value.to_s)
  end
end
