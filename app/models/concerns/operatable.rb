module Operatable
  extend ActiveSupport::Concern

  def add_operation object
    targets = object.is_a?(Array) ? object : [object]
    targets.each do |target|
      self.operations.create "#{target.class.name.downcase}_id" => target.id
    end
  end
end