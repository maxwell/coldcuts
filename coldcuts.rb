require 'csv'
require 'chronic'
require 'active_support/all'

path = '/Users/maxwell/Sites/coldcuts/grid.csv'

csv = CSV.open(path, headers:true, header_converters:[lambda { |x| x.to_s.strip }, :downcase, :symbol])


good_rows = csv.to_a.find_all do |row|
  last_email = Chronic.parse(row[:date_of_last_email])

  last_email && (row[:second_contact] || row[:third_contact]) && 
  row[:date_of_last_email] &&
  row[:met_goal] != 'Failed' &&
  row[:status] == 'Cold' && last_email < 3.days.ago
end

r1_rows = good_rows.find_all do |row|
    date = Chronic.parse(row[:second_contact])
    Time.now <= date && 
    date < (Time.now + 7.days) 
end

r2_rows = good_rows.find_all do |row|
    date = Chronic.parse(row[:third_contact])
    
    date <= Time.now && 
    date > (Time.now - 7.days)
end


def make_csv(title, rows)
  CSV.open("#{Time.now.month}.#{Time.now.day}-#{title}.csv", 'wb') do |csv|

    csv << ['project_name', 'website_link', 'platform', 'email', 'relationship id', 'last email']
    
    
    rows.each do |row|
      
      csv << [row[:relationship_name], row[:project_url], row[:platform], row[:contact_email], row[:relationship_id], row[:email_received]]
    end
  end
end


make_csv('R1', r1_rows)
make_csv('R2', r2_rows)
