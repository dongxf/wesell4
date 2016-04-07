# encoding: utf-8

class MemberCardUploader < BaseVersionUploader
  VERSIONS = {
    'large' => { width: 540, height: 300 },
    'thumb' => { width: 180, height: 100 }
  }
end
