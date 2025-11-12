# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # Override the create action to handle pending map data after sign up
  def create
    super do |resource|
      # If user successfully signed up and there's pending map data, redirect to create the map
      if resource.persisted? && session[:pending_map_data].present?
        # The pending map data will be picked up by the maps#create action
        # We'll redirect there after sign up instead of the default path
        return redirect_to maps_path, notice: "Welcome! Now let's create your map."
      end
    end
  end

  protected

  # Override the after_sign_up_path to redirect to maps#new with pending data
  def after_sign_up_path_for(resource)
    if session[:pending_map_data].present?
      # Keep the session data for now, will be used in maps#create
      new_map_path
    else
      super
    end
  end
end
