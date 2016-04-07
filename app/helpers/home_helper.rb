module HomeHelper
  def resource
    User.new
  end

  def resource_name
    :user
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  REGEXEN = {}

  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption cite code col colgroup command data datagrid datalist dd del details dfn div dl dt em embed eventsource fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link mark map menu meta meter nav noscript object ol optgroup option output p param pre progress q ruby rp rt s samp script section select small source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr)
  ADDITIONAL_HTML_TAG = %w(&nbsp; &copy;)

  REGEXEN[:HTML_TAGS] = /<\/?(#{HTML_TAGS.join('|')}).*?\/?>/im
  REGEXEN[:ADDITIONAL_HTML_TAG] = /(#{ADDITIONAL_HTML_TAG.join('|')};?)/m

  def remove_html_tag str
    return '' if str.nil?
    str.gsub(REGEXEN[:HTML_TAGS], ' ').gsub(REGEXEN[:ADDITIONAL_HTML_TAG], ' ')
  end

  def get_image_url(topic)
    content = topic.posts.first.text
    doc = Nokogiri::HTML(content)
    img_srcs = doc.css('img').map { |i| i['src'] }
    first_img = img_srcs.first
  end
end