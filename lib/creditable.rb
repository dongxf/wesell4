module Creditable
  TABLE = {
    sms: 10,
    lottery: 80
  }

  class CreditNotEnough < ::StandardError
  end

  def calculate_credit model
    if self.credit > TABLE[model]
      self.update_attribute :credit, self.credit - TABLE[model]
    else
      raise CreditNotEnough
    end
  end
end