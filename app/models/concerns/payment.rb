module Payment
  # STATUS = {
  #   "失败" => -1,
  #   "未付" => 0,
  #   "成功" => 1
  # }

  STATUS = %w{init success failure}

  HUAMAN_STATUS = {
    init: "未付款",
    success: "成功",
    failure: "失败"
  }

  STATUS.each do |s|
    define_method "#{s}?" do
      self.status == STATUS.index(s)
    end

    define_method "#{s}!" do
      self.status = STATUS.index(s)
      self.save
    end
  end

  def human_status
    STATUS[status]
  end
end
