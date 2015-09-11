require 'global_phone/database_generator'
require 'open-uri'

RESOURCE_URI = "https://raw.githubusercontent.com/googlei18n/libphonenumber/master/resources/PhoneNumberMetadata.xml"

namespace :global_phone do
  task :generate => :environment do
    generator = GlobalPhone::DatabaseGenerator.load(open(RESOURCE_URI).read)
    result = generator.record_data
    output = Rails.root.join('db/global_phone.json')
    File.write(output, JSON.generate(result))
    puts "Database successfully written to #{output}"
  end
end
