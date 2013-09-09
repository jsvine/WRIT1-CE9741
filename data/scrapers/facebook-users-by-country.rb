#!/usr/bin/env ruby
require "nokogiri"
require "httparty"

URL = "http://en.wikipedia.org/wiki/Facebook_statistics"

# Fetch and parse the page
html = HTTParty.get(URL).body
dom = Nokogiri::HTML(html)

# Get the main table
table = dom.css("table.wikitable").first

# [1..-1] skips the header row
rows = table.css("tr")[1..-1]

# Extract the country and FB users columns
data = rows.map do |row|
    cells = row.css("td")
    country = cells[1].css("a").text
    fb_users = cells[4].text.gsub(",", "")
    [ country, fb_users ]
end

header = [[ "country", "fb_users" ]]
csv = (header + data).map do |line|
    line.join(",")
end.join("\n")

puts csv
