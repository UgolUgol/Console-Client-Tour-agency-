require 'oci8'
connect = OCI8.new('nikita/Fizusa26@ORCL')
cursor = connect.exec('select * from tours')
while r = cursor.fetch()
	puts r.join(' ')
end
cursor.close
connect.logoff