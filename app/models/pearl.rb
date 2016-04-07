class Pearl < ActiveRecord::Base
  validates_presence_of :name, :email, :phone

  after_create :notify

private

  def notify
    PearlMailer.delay.signup(self)
    @printer = Printer.find_by imei: '4600790643318875'
    @printer.print digest
  end

  def digest
    msg = ''
    msg += "编号："+"#{self.id}\n"
    msg += "注册时间："+"#{self.updated_at.in_time_zone('Beijing').strftime("%Y-%m-%d %H:%M")}\n"
    msg += "<Font# Bold=0 Width=1 Height=2>姓名：#{self.name if self.name}</Font#>\n"
    msg += "<Font# Bold=0 Width=1 Height=2>电话：#{self.phone if self.phone}</Font#>\n"
    msg += "<Font# Bold=0 Width=1 Height=2>邮箱：#{self.email if self.email}</Font#>\n"
    msg += "<Font# Bold=0 Width=1 Height=2>学校：#{self.tutor if self.tutor}</Font#>\n"
  end
end
