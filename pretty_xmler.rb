require "rexml/document"

class PrettyXml
	def init(source)
		source = source.encode(Encoding::UTF_8)
		@doc = REXML::Document.new(source)
		@formatter = REXML::Formatters::Pretty.new
	end

	def write_to_console
		@formatter.compact = true
		@formatter.write(@doc, $stdout)
	end
end




