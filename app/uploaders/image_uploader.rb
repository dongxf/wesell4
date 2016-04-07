# encoding: utf-8

class ImageUploader < BaseVersionUploader
  VERSIONS = {
    'large' => { width: 300, height: 300 },
    'thumb' => { width: 80, height: 80 }
  }
end
