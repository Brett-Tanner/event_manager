require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode)
    zipcode = zipcode.to_s.dup.rjust(5, "0")[0..4]
end

contents = CSV.open(
    "event_attendees.csv", 
    headers: true, 
    header_converters: :symbol
)

contents.each do |attendee|
    name = attendee[:first_name]
    zipcode = clean_zipcode(attendee[:zipcode])

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        legislators = legislators.officials
    rescue
        legislators = 'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
    

    puts "#{name}: #{zipcode} #{legislators}"
end