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

def time?(registration_date)
    time = Time.strptime(registration_date, "%m/%e/%y %k:%M")
end

def print_reg_times(reg_times)
    sorted_times = reg_times.sort_by(&:last).reverse
    time_sentences = sorted_times.map do |array| 
        if array[1] == 1
            "#{array[1]} person signed up at #{array[0]}:00."
        else
            "#{array[1]} people signed up at #{array[0]}:00."
        end
    end
    puts "#{time_sentences.join("\n")}"
end

def print_reg_days(reg_days)
    sorted_days = reg_days.sort_by(&:last).reverse
    # use to transform days from int without long case
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    day_sentences = sorted_days.map do |array|
        array[0] = days[array[0]]
        if array[1] == 1
            "#{array[1]} person signed up on #{array[0]}."
        else
            "#{array[1]} people signed up on #{array[0]}."
        end
    end
    puts "#{day_sentences.join("\n")}"
end

contents = CSV.open(
    "event_attendees.csv", 
    headers: true, 
    header_converters: :symbol
)

template_letter = ERB.new(File.read("form_letter.erb"))

# store the frequency of registration for each time adn day
reg_times = Hash.new(0)
reg_days = Hash.new(0)

contents.each do |attendee|
    # info for letter
    id = attendee[0]
    name = attendee[:first_name]
    zipcode = clean_zipcode(attendee[:zipcode])

    phone_number = clean_phone(attendee[:homephone])

    reg_datetime = time?(attendee[:regdate])
    reg_times[reg_datetime.hour] += 1
    reg_days[reg_datetime.wday] += 1

    legislators = legislators_by_zip(zipcode)

    personal_letter = template_letter.result(binding)

    create_letter(personal_letter, id)
end

print_reg_times(reg_times)
print_reg_days(reg_days)