class StaticController < ApplicationController
  def about
  end

  def guidelines

  end

  def javascript_lab
  	if Rails.env.production?
  		redirect_to root_path
  	end
  end
end
