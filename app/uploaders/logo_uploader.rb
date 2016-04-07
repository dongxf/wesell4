# encoding: utf-8

class LogoUploader < BaseVersionUploader
  VERSIONS = {
    'large' => { width: 100, height: 100 },
    'thumb' => { width: 80, height: 80 }
  }
end
