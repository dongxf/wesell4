# encoding: utf-8

class ViLogoUploader < BaseVersionUploader
  VERSIONS = {
    'banner' => { width: 640, height: 320 },
    'large' => { width: 100, height: 100 },
    'thumb' => { width: 80, height: 80 }
  }

  def default_url
  	ActionController::Base.helpers.asset_path([version_name, "foowcn-vi-logo.jpeg"].compact.join('_'))
  end
end
