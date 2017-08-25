module MailboxerHelper
  def sanitize(input)
    input.html_safe? ? input : strip_tags(input)
  end
end
