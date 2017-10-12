class AddUserToMailchimp
	include Service

  def call(user)
    if user.subscribed
      gb = Gibbon::Request.new
      gb.lists.subscribe({ :id => ENV['MAILCHIMP_LIST_ID'],
                           :email => { :email => "#{user.email}"},
                           :merge_vars => { :FNAME => "#{user.name}" } })
    end
  end

end
