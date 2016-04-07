module Spreadable
  extend ActiveSupport::Concern

  def gen_sceneid
    raise "Instance method :gen_sceneid is not defind in #{self}"
  end

  def get_sceneid
    gen_sceneid if self.sceneid.blank?
    return self.sceneid
  end
end