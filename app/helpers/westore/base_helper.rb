module Westore::BaseHelper
  def nav_link active_link, options = {}, &block
    if @active_link == active_link
     if options[:class]
       options[:class] += ' onactive'
     else
       options[:class] = 'onactive'
     end
    end
    content = capture(&block)
    content_tag(:li, content, options)
  end
end
