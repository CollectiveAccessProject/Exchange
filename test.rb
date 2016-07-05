require 'mysql2'

i=0
while (i < 5)
	puts "Hello world #{i}!\n"
	i = i + 1
end

client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "seagate")

results = client.query("SELECT * FROM ca_users")

results.each do |row|
	puts "User is " + row['user_name'] + "\n"
end

(1..10).each do |i| 
 	puts "range=#{i}\n"
end