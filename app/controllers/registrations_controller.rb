class RegistrationsController < Devise::RegistrationsController
  # layout 'platform'

  protected
  def sign_up(resource_name, resource)
    user = super
    #user.load_default
  end
end
