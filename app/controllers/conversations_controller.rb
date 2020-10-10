# frozen_string_literal: true

# Controller for conversations of EBWiki messages
class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @other_users = User.where.not(id: current_user.id).pluck(:name, :id)
  end

  def create
    recipients = User.where(id: conversation_params[:recipients])
    conversation = current_user
                   .send_message(recipients,
                                 conversation_params[:body],
                                 conversation_params[:subject])
                   .conversation
    flash[:success] = 'Your message was successfully sent!'
    redirect_to conversation_path(conversation)
  end

  def show
    @receipts = conversation.receipts_for(current_user)
    # mark conversation as read
    conversation.mark_as_read(current_user)
  end

  def reply
    current_user.reply_to_conversation(conversation, message_params[:body])
    flash[:notice] = 'Your reply message was successfully sent!'
    redirect_to conversation_path(conversation)
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to mailbox_inbox_path
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to mailbox_inbox_path
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:subject, :body, recipients: [])
  end

  def message_params
    params.require(:message).permit(:body, :subject)
  end
end
