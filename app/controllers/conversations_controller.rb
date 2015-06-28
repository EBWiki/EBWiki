class ConversationsController < ApplicationController
	before_action :authenticate_user!

	def new
		
	end

	def create
		recipients = User.where(id: conversation_params[:recipients])
		conversation = current_user.send_message(recipients, conversation_params[:body], conversation_params[:subject]).conversation
		flash[:success] = "Your message was successfully sent!"
		redirect_to conversation_path(conversation)
	end

	def show
		@receipts = conversation.receipts_for(current_user)
		# mark conversation as read
		conversation.mark_as_read(current_user)
	end

	def reply
		current_user.reply_to_conversation(conversation, message_params[:body])
		flash[:notice] = "Your reply message was successfully sent!"
		redirect_to conversation_path(conversation)
	end

private
  
  def conversation_params
  	paramsrequire(:conversation).permit(:subject, :body, recipients:[])
  end
end
