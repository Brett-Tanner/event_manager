# if File.exist?("event_attendees.csv")
#     contents = File.read("event_attendees.csv")
#     puts contents
# else
#     puts "File not found"
# end

if File.exist?("event_attendees.csv")
    attendee_array = File.readlines("event_attendees.csv")
    attendee_array = attendee_array.map {|attendee| attendee.split(",")}
    attendee_array.each {|attendee| puts attendee[2]}
else
    puts "File not found"
end