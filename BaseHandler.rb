require 'dbi'
require 'oci8'
require 'nokogiri'
require 'colorize'
load 'pretty_xmler.rb'
load 'CondsParser.rb'


class BaseHandler
	def init_connection(username, password)
		begin
			@conn = DBI.connect('DBI:OCI8:', username, password)
			@parser = CondsParser.new
			puts "Successful connection to #{username}"
		rescue DBI::DatabaseError => e
     		puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end

	def close_connection
		if @conn.nil?
			puts "An error occurred"
			puts "Error message: you don't connected to base"
		else
			@conn.disconnect 
			puts "Successful disconnetion"
		end
	end

	def print_table(sth)
		rows = sth.fetch_all
		xml_table = []
		rows.each do |row|
			xml_table.push(row[0])
		end
		xml_string = '<database>' + xml_table.join() + '</database>'
		@xml_data = Nokogiri::XML(xml_string) 
		@xml_data
	end

	def get_colnames(table, with_type=false)
		sql = 'select column_name, data_type from user_tab_columns where table_name = ' + '\'' + table.upcase + '\''
		sth = @conn.prepare(sql)
		sth.execute 
		cnames = sth.fetch_all
		coltypes_list = {}
		col_list = []
		cnames.each do |row|
			if !with_type
				col_list.push(row[0])
			else
				coltypes_list[row[0]] = row[1]
			end
		end
		if with_type
			coltypes_list
		else 
			col_list
		end
	end

	def send_to_parse(table, columns, value, type)
		parsed = ""
		coltypes = get_colnames(table, true)
		if type == 'cond'
			parsed = @parser.cond_parse(value, columns, coltypes)
		elsif type == 'insert'
			parsed = @parser.insert_parse(value, columns, coltypes)
		else
			parsed = @parser.set_parse(value, coltypes)
		end
		parsed
	end

	def xml_sql(what, from, where)
		out_colnames = []
		if what == '*'
			out_colnames = get_colnames(from).join(", ").downcase
		else
			out_colnames = what
		end
		sql = 'select xmlelement("Data", xmlforest(' + out_colnames +')) from ' + from
		if where.nil? == false 
			# here parse conds
			sql += ' where ' + where
		end
		sql
	end 


	def select(what, from, where=nil)
		sql = xml_sql(what, from, where)
		puts sql
		begin
			sth = @conn.prepare(sql)
			sth.execute
			table = self.print_table(sth) 
			sth.finish

			page_size = 5
			left_border = 1
			right_border = left_border + page_size
			len = table.xpath("//Data").length
			while left_border < len
				for i in left_border..right_border-1
					puts table.xpath("//Data")[i-1]
				end
				puts "press <enter> to next".green
				a = gets
				left_border = right_border
				right_border = (right_border + page_size < len ? right_border + page_size : len + 1)

			end
		rescue DBI::DatabaseError => e
     		puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end

	def select_into_file(path, what, from, where=nil)
		table = select(what, from, where)
			open(path, 'w') do |f|
				f.puts table 
			end
	end


	def insert(into, columns, values)
		sql = 'insert into ' + into
		if columns != '*'
			sql += ' (' + columns + ')'
		else
			columns = get_colnames(into).join(", ").downcase
			sql += ' (' + columns + ')'
		end
		proc_values = send_to_parse(into, columns, values, 'insert')
		sql += ' values(' + proc_values + ')'
		begin 
			sth = @conn.prepare(sql)
			sth.execute()
			@conn.commit
			puts "successfull insert".blue
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end


	def update(table, set_args, where=nil)
		#set_args example : col1=val1, col2=val2, col3=val3, ...
		sql = 'update ' + table + ' set '

		#converting args to right types
		typed_set_args = send_to_parse(table, nil, set_args, 'update')
		sql += typed_set_args
		if where.nil? == false 
			sql += ' where ' + where
		end
		puts sql
		begin 
			sth = @conn.prepare(sql)
			sth.execute()
			@conn.commit
			puts "successfull update".blue
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end

	def delete(table, where)
		sql = 'delete from ' + table + " where " + where
		begin 
			sth = @conn.prepare(sql)
			sth.execute
			@conn.commit
			puts "successfull delete".red
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end

	def reserve(user_name, email, phone, tid)
		begin
			sth = @conn.prepare("CALL MAKE_RESERVE(?,?,?,?,?)");
			sth.execute(user_name, email, phone, tid, 1)
			@conn.commit
			self.select("login, pass", "enter_data", "login="+"\'"+email+"\'")
			puts "successfull reserve".green
		rescue DBI::DatabaseError => e
			puts "An error occurred"
			puts "Error code: #{e.err}"
			puts "Error message: #{e.errstr}"
		end
	end
end
