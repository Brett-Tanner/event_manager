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
        # This still prints the full error trace from the API to the console
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

def create_letter(letter, id)
    Dir.mkdir("output") unless Dir.exist?("output")

    filename = "output/thanks_#{id}.html"

    File.open(filename, "w") {|file| file.puts letter}
end

def clean_phone(number)
    number = number.tr("^0-9", "")
    case number.length
    when 0..9
        number = "Your number is too short"
    when 11
        if number.start_with?("1")
            number = number[1..9]
        else
            number = "11 digit numbers must start with '1'"
        end
    when (11..)
        number = "Your number is too long"
    else
        number
    end
end

contents = CSV.open(
    "event_attendees.csv", 
    headers: true, 
    header_converters: :symbol
)

template_letter = ERB.new(File.read("form_letter.erb"))

contents.each do |attendee|
    id = attendee[0]
    name = attendee[:first_name]
    zipcode = clean_zipcode(attendee[:zipcode])
    phone_number = clean_phone(attendee[:homephone])

    legislators = legislators_by_zip(zipcode)

    personal_letter = template_letter.result(binding)

    create_letter(personal_letter, id)
end

