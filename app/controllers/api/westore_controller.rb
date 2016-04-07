#encoding: utf-8
#让外网连接fooways的微信打印机
#参数和路由与老版本兼容
class Api::WestoreController < Api::ApplicationController

  def print_text
    store   = Store.find(params[:westore]) if params[:westore]
    content = params[:content]

    if store && content && store.users.include?(@user)
      store.printers.each do |printer|
        printer.copies.times do |i|
          printer.print ">>>>第#{i+1}联\n" + content
          if printer.status != 'okey'
            render text: printer.status
            return
          end
        end
      end
      render text: 'okey'
    else
      render text: 'Invalid params, please check api document', status: 404
    end
  end

end
