class Platform::CustomersController < Platform::BaseController
  def index
    if current_user.admin?
      @customers = Customer.includes(:instance).page params[:page]
    else
      @customers = current_user.customers.identified.includes(:instance).page params[:page]
    end

    if params[:status] == "sub"
      @customers = @customers.sub.page params[:page]
    elsif params[:status] == "unsub"
      @customers = @customers.unsub.page params[:page]
    end
  end

  def show
    @customer = Customer.find(params[:id])
    @member = @customer.member
  end

  def switch
    customer = Customer.find params[:id]
    customer.toggle!(:status)
    message = customer.normal? ? "已经解封" : "已经拉黑"
    render text: message, layout: false
  end

private

  def customer_params
    params.require(:customer).permit!
  end
end
