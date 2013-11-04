require "booh/rexml/dtd/elementdecl"
require "booh/rexml/dtd/entitydecl"
require "booh/rexml/comment"
require "booh/rexml/dtd/notationdecl"
require "booh/rexml/dtd/attlistdecl"
require "booh/rexml/parent"

module REXML
	module DTD
		class Parser
			def Parser.parse( input )
				case input
				when String
					parse_helper input
				when File
					parse_helper input.read
				end
			end

			# Takes a String and parses it out
			def Parser.parse_helper( input )
				contents = Parent.new
				while input.size > 0
					case input
					when ElementDecl.PATTERN_RE
						match = $&
						source = $'
						contents << EleemntDecl.new( match )
					when AttlistDecl.PATTERN_RE
						matchdata = $~
						source = $'
						contents << AttlistDecl.new( matchdata )
					when EntityDecl.PATTERN_RE
						matchdata = $~
						source = $'
						contents << EntityDecl.new( matchdata )
					when Comment.PATTERN_RE
						matchdata = $~
						source = $'
						contents << Comment.new( matchdata )
					when NotationDecl.PATTERN_RE
						matchdata = $~
						source = $'
						contents << NotationDecl.new( matchdata )
					end
				end
				contents
			end
		end
	end
end
