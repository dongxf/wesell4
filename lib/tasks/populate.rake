namespace :db do
  task populate: :environment do
    Meetup.destroy_all
    10.times do
      Meetup.create(
        name: Faker::Name.first_name + " " + Faker::Name.last_name,
        comment: Faker::HipsterIpsum.words(10).join(' ')
      )
    end
  end
end
