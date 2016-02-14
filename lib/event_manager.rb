require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_letters(id,letter)
  Dir.mkdir("output") unless Dir.exists?("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename,'w') do |file|
    file.puts letter
  end
end


puts "Event Manager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zip)
  form_letter = erb_template.result(binding)
  save_letters(id,form_letter)
end

puts "Event Manager Finished!"
