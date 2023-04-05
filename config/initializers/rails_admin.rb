# frozen_string_literal: true

RailsAdmin.config do |config|
  ### Popular gems integration

  ## == Devise == |config|
  config.authorize_with do |_controller|
    unless current_user.try(:admin?)
      flash[:error] = 'You are not an admin'
      redirect_to main_app.root_path
    end
  end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  
  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except ['CalendarEvent']
    end
    export do
      except ['CalendarEvent']
    end
    bulk_delete do
      except ['CalendarEvent']
    end
    show do
      except ['CalendarEvent']
    end
    edit do
      except ['CalendarEvent']
    end
    delete do
      except ['CalendarEvent']
    end
    show_in_app do
      except ['CalendarEvent']
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # class RailsAdmin::Config::Fields::Types::Uuid < RailsAdmin::Config::Fields::Base
  #   RailsAdmin::Config::Fields::Types.register(self)
  # end
end
