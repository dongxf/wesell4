class Platform::LicensesController < Platform::BaseController
  before_filter :admin_required
  def create
    create! { platform_licenses_path }
  end

  private
  def license_params
    params.require(:license).permit!
  end
end
