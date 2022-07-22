require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
    zipcode = zipcode.to_s.dup.rjust(5, "0")[0..4]
end

def legislators_by_zip(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue Google::Apis::ClientError => e
        # FIXME: This still prints the full error trace from the API
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

contents = CSV.open(
    "event_attendees.csv", 
    headers: true, 
    header_converters: :symbol
)

template_letter = ERB.new(File.read("form_letter.erb"))

contents.each do |attendee|
    name = attendee[:first_name]
    zipcode = clean_zipcode(attendee[:zipcode])

    legislators = legislators_by_zip(zipcode)

    personal_letter = template_letter.result(binding)

    puts "#{personal_letter}"
end

