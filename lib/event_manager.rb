# Without parser
# if File.exist?("event_attendees.csv")
#     contents = File.read("event_attendees.csv")
#     puts contents
# else
#     puts "File not found"
# end

# if File.exist?("event_attendees.csv")
#     attendee_array = File.readlines("event_attendees.csv")
#     attendee_array = attendee_array.map {|attendee| attendee.split(",")}
#     attendee_array.each_with_index {|attendee, index| puts attendee[2] if index != 0}
# else
#     puts "File not found"
# end

require 'csv'

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)
# contents.each {|attendee| puts attendee[2]}

contents.each do |attendee|
    name = attendee[:first_name]
    zipcode = attendee[:zipcode]
    
    if zipcode == nil
        zipcode = "00000"
    end
    while zipcode.length > 5
        zipcode = zipcode.chop
    end
    while zipcode.length < 5
        zipcode = zipcode.insert(0, "0")
    end
   
    puts "#{name}: #{zipcode}"
end
