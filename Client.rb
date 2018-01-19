load 'BaseHandler.rb'

obj = BaseHandler.new
obj.init_connection('nikita', 'Fizusa26')
puts "q [select|insert|update|delete]"
puts "	[select]: [attributes] [from] [where]"
puts "	[insert]: [table] [columns] [values]"
puts "	[update]: [table] [atr1=val1,atr2=val2,...] [where]"
puts "	[delete]: [table] [where]"
puts "reserve - reserve tour"
puts "exit - exit program"

while true
	print "command: "
	cmd_line = gets
	cmd = cmd_line.split(" ")
	if cmd[0] == "q"
		qtype = cmd[1]
		if qtype == "select"
			print "attrs: "
			what = gets.chomp
			print "from: "
			from = gets.chomp
			print "where(print \"not\" if without where): "
			where = gets.chomp
			if where != 'not'
				obj.select(what, from, where)
			else
				obj.select(what, from)
			end
		elsif qtype == "insert"
			print "table name: " 
			tname = gets.chomp
			print "columns: "
			cnames = gets.chomp
			print "values: "
			vals = gets.chomp
			obj.insert(tname, cnames, vals)
		elsif qtype == "update"
			print('table name: ')
			tname = gets.chomp 
			print("set args(attr = val, ..., ): ")
			set_args = gets.chomp;
			print "where(print \"not\" if without where): "
			where = gets.chomp;
			if where != 'not'
				obj.update(tname, set_args, where)
			else
				obj.update(tname, set_args)
			end
		elsif qtype == "delete"
			print("table name: ")
			tname = gets.chomp
			print("where: ")
			where = gets.chomp
			obj.delete(tname, where)
		else
			puts "wrong query type"
		end
	elsif cmd[0] == 'reserve'
		obj.select("*", "tours")
		print("Name: ")
		user_name = gets.chomp
		print("Email: ")
		email = gets.chomp
		print("Phone: ")
		phone = gets.chomp
		print("Tour id: ")
		tid = gets.to_i
		obj.reserve(user_name, email, phone, tid);
	end
		
end
			
			



obj.select('*', 'avia', where)
#obj.update('avia', 'departure_time=16:00, from_city=Kiev')
#obj.insert('avia', '*', '2, boeing-575, Moscow, Paris,  12:30,  15:30')
obj.close_connection
