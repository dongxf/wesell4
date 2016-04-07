require 'csv'
namespace :import_data do
  desc "import data from csv"
  task :from_csv, [:village_id] => :environment do |task, args|
    csv_file = File.read('public/village_items.csv')
    csv = CSV.parse(csv_file, :headers => true)

    csv.each do |row|
      attrs = row.to_hash.merge({village_id: args[:village_id], level: 0})
      vi = VillageItem.new attrs
      vi.save(validate: false)
    end
  end
end

# require 'csv'
# csv_file = "tmp/test.csv"
# h = ["name", "tel", "addr", "opening_hours","takeout", "info", "meta", "village_id", "sub_tags", "remark", "user_email"]
# csv_read = CSV.read csv_file, headers: true
# new_csv = CSV.open(csv_file, 'w') do |csv|
#   csv << h
#   csv_read.each_with_index do |row|
#     csv.puts row
#   end
# end.delete_if { |row| row.to_hash.values.all?(&:blank?) }

# csv_read = CSV.read(csv_file, headers: true).delete_if { |row| row.to_hash.values.all?(&:blank?) }

# csv_read.each do |row|
#   sub_tags = row["sub_tags"].split(/,|，/)
#   user_email = row["user_email"]
#   village_ids = row["village_id"]

#   attrs = row.to_hash.merge({level: 0})
#   attrs.delete nil
#   attrs.delete 'sub_tags'
#   attrs.delete 'user_email'
#   attrs.delete 'village_id'
#   vi = VillageItem.new attrs
#   vi.save(validate: false)

#   vi.sub_tag_list = sub_tags
#   vi.village_list = village_ids
#   user = User.find_by email: user_email
#   UserVillageItem.create(user_id: user.id, village_item_id: vi.id) if user.present?
# end