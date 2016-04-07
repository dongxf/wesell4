# encoding: utf-8

class ViBannerUploader < BaseVersionUploader
  VERSIONS = {
    'large'  => { width: 640, height: 355 },
    'medium' => { width: 360, height: 200 },
    'thumb'  => { width: 180, height: 100 }
  }

  def default_url
    ActionController::Base.helpers.asset_path([version_name, "fbooks-b.jpg"].compact.join('_'))
  end
end
