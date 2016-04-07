# encoding: utf-8

class BannerUploader < BaseVersionUploader
  VERSIONS = {
    'large'  => { width: 640, height: 355 },
    'medium' => { width: 360, height: 200 },
    'thumb'  => { width: 180, height: 100 }
  }
end
