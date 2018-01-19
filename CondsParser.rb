require 'dbi'

class CondsParser
	def args_proc(args, columns, coltypes)
		new_args = []
		n = args.size-1
		for i in 0..n
			x = columns[i].upcase
			arg = args[i]
			if /INTERVAL*/ =~ coltypes[x]
				put_line = 'to_dsinterval(\'0 ' + arg +':00\')'
				new_args.push(put_line)
			elsif /CHAR*/ =~ coltypes[x] or /VARCHAR*/ =~ coltypes[x]
				put_line = '\'' + arg + '\''
				new_args.push(put_line)
			elsif /NUMBER*/ =~ coltypes[x]
				new_args.push(arg)
			end
		end
		new_args
	end

	def set_parse(set_args, coltypes)
		equals = set_args.split(", ")

		typed_set_args = []
		equals.each do |equal|
			splited_equal = equal.split("=")
			arg = splited_equal[1]
			column = splited_equal[0]
			new_val = args_proc([arg], [column], coltypes)[0]					
			colname = (column + '=')
			typed_set_args.push(colname + new_val)
		end
		typed_set_args.join(', ')
	end

	def insert_parse(value, columns, coltypes)
		new_vals = args_proc(value.split(', '), columns.split(', '), coltypes)
		new_vals.join(', ')
	end
end 