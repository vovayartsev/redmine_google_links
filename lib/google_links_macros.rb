# Wiki Extensions plugin for Redmine
# Copyright (C) 2010 Vladimir Yartsev
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
require 'redmine'
require 'uri'

module WikiExtensionsWikiMacro

	#TODO: support for corporate google accounts 
	# For "corporate" gmail accounts, the link to e-mail search page differs from mail.google.com (the "domain" is different from "google.com")
	# The function below makes it possible to specify the domain on per-user basis using custom fields.
	# Just create a custom field named "GMail Domain" for users and put your users' domains there.
	# If "GMail Domain" custom field value is empty - don't display the link at all (print it in plaintext).

	def self.get_link_for(subject, type)
		param = subject.gsub(/ /, "+")

		# If no current user - no link is displayed
		return nil if !User.current || !User.current.id

		# Default GMAIL domain
		domain = "google.com"

		# Checking the custom field value
		field = UserCustomField.first(:all, :conditions => {:name => "GMail Domain"})	

		# If the field is found - use it's value for GMAIL domain
		if field
			custom_value = CustomValue.first(:conditions => {:customized_type => "User", :customized_id => User.current.id, :custom_field_id => field.id})
			return nil if custom_value.nil? || custom_value.value == ""
			domain = custom_value.value
		else
			# if the custom field is not found - just use the standard domain instead
		end

		# Displaying the result depending on the custom field logic
		case type
		when :mail
			return "https://mail." + domain + "/mail/?#search/" + URI.escape(param)
		when :doc
			return "https://docs." + domain + "/?#search/" + URI.escape(param)
		else
			return nil
		end
	end


	Redmine::WikiFormatting::Macros.register do
		desc "Inserts a link to GMail e-mail or Google Doc\n"

		macro :gdoc  do |obj, args|
			subject = args.join(",")
			link =  WikiExtensionsWikiMacro::get_link_for(subject, :doc)

			subject.gsub!(/(#\d+)/, "!\\1")
			if link	
				return "<a href='#{link}' target='_blank'>#{h(subject)}</a>"
			else
				return h(subject)
			end
		end

		macro :gmail  do |obj, args|
			subject = args.join(",")
			link =  WikiExtensionsWikiMacro::get_link_for(subject, :mail)

			subject.gsub!(/(#\d+)/, "!\\1")
			if link	
				return "<a href='#{link}' target='_blank'>#{h(subject)}</a>"
			else
				return h(subject)
			end
		end
	end
end
