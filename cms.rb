#! /usr/bin/env ruby

require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'

ROOT = File.expand_path('..', __FILE__)

configure do
  set :sessions, expire_after: 365*24*60*60
  set :session_secret, 'secret'
end

# Homepage displays list of files
get '/' do
  @docs = Dir.glob(ROOT + '/data/*').map { |file| File.basename(file) }
  erb :index
end

def markdown_html(markdown_str)
  markdown = Redcarpet::Markdown::new(Redcarpet::Render::HTML)

  markdown.render(markdown_str)
end

# Returns error message or nil
def file_error(file_path)
  unless File.exists?(file_path)
    file = File.basename(file_path)
    session[:message] = "#{file} does not exist."
  end
end

# Displays a file's contents
get '/:file_name' do |file|
  file_path = ROOT + "/data/" + file

  redirect "/" if file_error(file_path) 

  contents = File.read(file_path)
  if File.extname(file) == '.md'
    markdown_html(contents)
  else
    headers("Content-Type" => "text/plain")
    contents
  end
end
