# frozen_string_literal: true

# Controller for users EBWiki messages
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def create
    recipients = User.where(id: message_params['recipients'])
    conversation = current_user.send_message(
                                              recipients,
                                              message_params[:message][:body],
                                              message_params[:message][:subject]
                                            ).conversation
    flash[:success] = 'Message has been sent!'
    redirect_to conversation_path(conversation), status: :created
  end

  private

  def message_params
    params.require(:message).permit(:body, :subject, recipients: [])
  end
end
