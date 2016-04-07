module Printable
  def print!
    print_flag = true
    self.store.printers.each do |printer|
      msg = printer.model == 'feyin' ? formatted_printable_text : printable_text
      printer.copies.times do |i|
      print_good = printer.print "#{printer.id}号机>>>>第#{i+1}联\n" + msg
      logger.info "======================="
      logger.info msg
      logger.info "======================="
      print_flag = false if !print_good
      end
    end
    return print_flag
  end

  def formatted_printable_text serial_number=true
    msg = ''
    msg += "编　号：#{self.id}\n"
    # 是否打印流水号（商家需要流水号，但顾客的微信通知要隐藏流水号）
    if serial_number
      msg += "流水号：店铺-#{self.serial_number}，平台-#{self.serial_number_instance}\n"
    end
    msg += "下单时间：#{self.submit_at.in_time_zone('Beijing').strftime('%Y-%m-%d %H:%M')}\n"
    msg += "付款方式：#{self.human_payment_option}\n"
    msg += "<Font# Bold=1 Width=1 Height=2>联系：#{self.contact}</Font#>\n"
    msg += "<Font# Bold=1 Width=1 Height=2>电话：#{self.phone}</Font#>\n"
    msg += "<Font# Bold=1 Width=1 Height=2>地址：#{self.address}</Font#>\n"
    msg += "<Font# Bold=1 Width=1 Height=2>预约时间：#{self.start_at}</Font#>\n"

    msg += "-------------------------------\n"
    msg += "商品名称　　　　　　　数量　小计\n"
    self.order_items.each do |itm|
      item_name = itm.wesell_item.name.ljust(12).gsub(' ','　')
      msg+= "#{item_name}#{itm.quantity}　#{itm.total_price.round(2)}\n"
      itm.order_item_options.each do |option|
        msg += "+ #{option.label(self.store)}\n"
      end
      msg+= "*#{itm.comment}\n" if itm.comment.present?
    end
    msg += "\n"
    self.order_options.each do |option|
      msg += "+ #{option.label(self.store)}\n"
    end
    if self.shipping_charge > 0
      msg += "运费：#{self.shipping_charge.to_f}\n"
    end
    msg += "备注：#{self.description}\n"
    msg += "-------------------------------\n"
    msg += "合计：#{self.amount.round(2)}#{self.monetary_unit}\n".rjust(28)
    msg += "\n"
    msg += "平台第#{self.csni}次惠顾\n"
    msg += "店铺：#{self.name}, 第#{self.csn}次惠顾\n"
  end

  def printable_text serial_number=true
    msg = "\n"
    msg += "编　号："+"#{self.id}\n"
    if serial_number
      msg += "流水号：店铺-#{self.serial_number}，平台-#{self.serial_number_instance}\n"
    end
    msg += "下单时间：#{self.submit_at.in_time_zone('Beijing').strftime('%Y-%m-%d %H:%M')}\n" if self.submit_at.present?
    msg += "付款方式：#{self.human_payment_option}\n"
    msg += "联系：#{self.contact}\n"
    msg += "电话：#{self.phone}\n"
    msg += "地址：#{self.address}\n"
    msg += "预约时间：#{self.start_at}\n" if self.start_at.present?
    msg += "-------------------------------\n"
    msg += "商品名称　　　　　　　数量　小计\n"
    self.order_items.each do |itm|
      item_name = itm.wesell_item.name.ljust(12).gsub(' ','　')
      msg+= "#{item_name}#{itm.quantity}　#{itm.total_price.round(2)}\n"
      itm.order_item_options.each do |option|
        msg += "+ #{option.label(self.store)}\n"
      end
      msg+= "*#{itm.comment}\n" if itm.comment.present?
    end
    msg += "\n"
    self.order_options.each do |option|
      msg += "+ #{option.label(self.store)}\n"
    end
    if self.shipping_charge > 0
      msg += "运费：#{self.shipping_charge.to_f}\n"
    end
    msg += "备注：#{self.description}\n"
    msg += "-------------------------------\n"
    msg += "合计：#{self.amount.round(2)}#{self.monetary_unit}\n".rjust(28)
    msg += "\n"
    msg += "平台第#{self.csni}次惠顾\n"
    msg += "店铺：#{self.name}, 第#{self.csn}次惠顾\n"
  end
end
