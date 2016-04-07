class PrintController < ApplicationController
  # after_action :clear

  def print
    #打印机状态 status (0为打印成功, 1为过热,3为缺纸卡纸等)?
    #打印job 状态 errno  -1 验证错误, #待打印, 已打印?
    # printer = Printer.find_by(:imei,)
    # @print_jobs = printer.print_jobs.where(to_print)


    tid = params[:tid]
    rsn = params[:rsn]
    sig = params[:sig]

    usr='test@fooways.com'
    passwd='hell0tstusr'
    key = "#{usr}#{rsn}#{passwd}"

    # logger.debug(key)

    md5_key = Digest::MD5.hexdigest(key).upcase

    # logger.debug(md5_key)

    @order = Order.where("submit_at IS NOT NULL").first

    unless md5_key == sig
      render "error"
    end
  end

  # private
  # def clear
  #   # @print_job.update_attributes(:status, )
  # end
end