# frozen_string_literal: true

class StaticController < ApplicationController
  def about; end

  def guidelines; end

  def javascript_lab
    redirect_to root_path if Rails.env.production?
  end
end
