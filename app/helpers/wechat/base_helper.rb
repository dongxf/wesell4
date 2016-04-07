module Wechat::BaseHelper
  def full_url url
    "#{ENV['WESELL_SERVER']}#{url}"
  end
end
