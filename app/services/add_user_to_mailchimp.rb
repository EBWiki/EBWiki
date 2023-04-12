# frozen_string_literal: true

class AddUserToMailchimp
  include Service
  def call(user)
    if user.subscribed # rubocop:todo Style/GuardClause
      gb = Gibbon::Request.new
      gb.lists.subscribe(id: ENV['MAILCHIMP_LIST_ID'],
                         email: { email: user.email.to_s },
                         merge_vars: { FNAME: user.name.to_s })
    end
  end
end
