class WestoreCell < Cell::Rails
  def kategories_list args
    @kategories = args[:kategories]
    @instance = args[:instance]
    render
  end

  def stores_list args
    @stores = args[:stores]
    @instance = args[:instance]
    render
  end

  def order_details args
    @order = args[:order]
    render
  end
end
