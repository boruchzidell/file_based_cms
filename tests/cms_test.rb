#! /usr/bin/env ruby

ENV["RACK_ENV"] = "test"

require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require 'rack/test'

require_relative '../cms.rb'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_markdown_html_method
    markdown_text = "# this is a header"
    html = "<h1>this is a header</h1>\n"

    assert_equal html, markdown_html(markdown_text)
  end

  def test_file_error_method
    current_file = File.expand_path(__FILE__)
    assert_nil file_error(current_file)

    non_existent = File.expand_path("..", __FILE__) + "nonexistent.txt"
  end

  def test_index 
    get "/"
    
    assert_equal 200, last_response.status
    assert_includes last_response["Content-Type"], "text/html"
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "change.txt"
    assert_includes last_response.body, "history.txt"
  end
  
  def test_non_existent_file
    get "/non_existent.txt"

    assert_equal 302, last_response.status

    # Follow the redirect
    get last_response["Location"]
    assert_includes last_response.body, "non_existent.txt does not exist"

    # Reload the page
    get "/"
    refute_includes last_response.body, "non_existent.txt does not exist"
  end

  def test_viewing_file_contents
    get "/about.txt"

    # Plaintext file
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Yukihiro Matsumoto"

    # Markdown file
    get "/about.md"
    assert_includes last_response.body, "<h1>Ruby</h1>\n\n<p>The best language ever.</p>"
  end


end
