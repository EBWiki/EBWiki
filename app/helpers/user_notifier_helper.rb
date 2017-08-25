module UserNotifierHelper
	def follow_message(user, is_subscribed)
		if user.all_following.count <= 0
			subscriber_note(is_subscribed) + "It is very important that you click to follow one or more cases and allow us to keep you up to date. The more people paying attention, the easier it will be effect change."
		else
			"You have already taken the first step by following #{ pluralize(user.all_following.count, 'case') } on EBWiki and allowing us to keep you up to date. #{subscribe_cta(is_subscribed)}"
		end
	end
	
	def subscriber_note(is_subscribed)
		if is_subscribed
			return "As a newsletter subscriber, you'll receive our general updates periodically. "
		end
		
		return ''
	end
	
	def subscribe_cta(is_subscribed)
		unless is_subscribed
			return "#{ link_to('Subscribe to our newsletter as well', ENV['MAILCHIMP_LINK']) } for periodic general updates and commentaries on this issue."
		end
		
		return ''
	end
end