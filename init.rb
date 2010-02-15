require 'redmine'

require 'google_links_macros'

Redmine::Plugin.register :redmine_google_links do
  name 'Redmine Google Links plugin'
  author 'Vladimir Yartsev'
  description 'This is a plugin for Redmine that allows referencing GDocs and GMails'
  version '0.0.1'
end
