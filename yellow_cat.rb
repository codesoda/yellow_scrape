require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

url_template = "http://www.yellowpages.com.au/nsw/categories-[LETTER][PAGENUMBER].html"

letters = ('a'..'z')

CSV.open("categories.csv", "w") do |csv|

  letters.each do |letter|
    pageNumber = 1
    while pageNumber > 0
      url = url_template.gsub('[LETTER]', letter).gsub('[PAGENUMBER]', pageNumber.to_s)
      puts "opening page #{letter}: " + url

      begin
        html = open(url)
        doc = Nokogiri::HTML(html)
        doc.css("#headingsContainer a").each do |listing|
          csv << [listing.content]
        end
        pageNumber = pageNumber + 1
      rescue
        pageNumber = -1
      end
    end
  
  end


end

