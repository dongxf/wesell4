#encoding: utf-8
module Monetary
  extend ActiveSupport::Concern

  TAGS = {
    "元"  => '¥',
    "港币" => '$',
    "日元" => '¥',
    "美元" => '$',
    "欧元" => '€',
    "英镑" => '£',
    "澳元" => '$'
  }

  included do
    before_validation :set_monetary_unit
  end

  def monetary_tag
    TAGS[self.monetary_unit]
  end

  def set_monetary_unit
    self.monetary_unit = '元' if self.monetary_unit.blank?
  end
end