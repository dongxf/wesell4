class Westore::MembersController < Westore::BaseController
  before_filter :active_link

  def index
    if current_customer.member.present?
      @member = current_customer.member
    else
      redirect_to action: :new
    end
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new member_params
    @member.instance = current_instance
    if @member.save
      current_customer.update_attribute :member_id, @member.id
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    resource.update_attributes member_params
    update! do |success, failure|
      success.html {redirect_to westore_members_path and return}
      failure.html { render :edit}
    end
  end

  def none

  end

private
  def member_params
    params.require(:member).permit!
  end

  def active_link
    @active_link = :members
  end
end
