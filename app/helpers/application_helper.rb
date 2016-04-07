module ApplicationHelper
  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-danger alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def main_nav(name, options = {}, &block)
    if @main_nav == name
      if options[:class]
        options[:class] += ' active'
      else
        options[:class] = 'active'
      end
    end
    content = capture(&block)
    content_tag(:li, content, options)
  end

  def distance obj1, obj2
    Geocoder::Calculations.distance_between([obj1.latitude, obj1.longitude], [obj2.latitude, obj2.longitude])
  end

  def format_time datetime
    datetime.strftime('%Y-%m-%d %H:%M')
  end

  def active_page(path)
    "active" if current_page?(path)
  end

  def add_class status
    return "active" if status == "all" && params[:status].nil?
    return "active" if params[:status] == status
  end

  def search_options
    if current_user.admin?
      [['公众号','instance'], ['运营', 'operation'], ['店铺','store'], ['商品', 'wesell_item'], ["订单","order"], ['用户','user'], ['黄页','village_item']]
    else
      [['店铺','store'], ['商品', 'wesell_item'], ['黄页', 'village_item']]
    end
  end
end
