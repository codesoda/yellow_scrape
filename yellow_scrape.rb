require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

url_template = "http://www.yellowpages.com.au/search/listings?showAllLocations=false&headingCode=34207&visitedIAPages=1&visitedIAPages=2&referredBy=www.yellowpages.com.au&eventType=pagination&selectedViewMode=list&emsLocationId=&sessionId=2F95A5CC4F6F5CC7C033E1BA34E91875.persist-191-1&stateId=9&clue=graphic+designers&context=businessTypeSearch&pageNumber=PAGE_NUMBER&lruPageNumber=1&locationClue=australia&toggleViewTriggeredCount=0"

pageNumber = 1

CSV.open("graphic_designers.csv", "w") do |csv|
  csv << ["id", "name", "phone", "email", "website", "address"]

  while pageNumber > 0
    url = url_template.gsub('PAGE_NUMBER', pageNumber.to_s)
    puts "opening page #{pageNumber}: " + url

    html = nil
    begin
      html = open(url)
    rescue
      sleep(2)
      html = open(url)
    end
    doc = Nokogiri::HTML(html)

    doc.css("#searchResultListings .listingContainer").each do |listing|

      id = listing.at_css(".compareSelector")['listingid']
      link = "http://www.yellowpages.com.au" + listing.at_css(".omnitureListingNameLink")['href'].to_s

      puts "opening listing #{id}: " + link
      html = nil
      begin
        html = open(link)
      rescue
        sleep(2)
        html = open(link)
      end
      page = Nokogiri::HTML(html)

      name = page.at_css(".listingName")

      phone = page.at_css(".preferredContactNumberDetails")
      phone_s = (phone ? phone.content.strip : "-")

      email = page.at_css(".emailBusinessLink")
      email_s = (email ? email.content.strip : "-")

      address = page.at_css(".listingAddress")
      address_s = (address ? address.content.strip : "-")

      website = page.at_css(".webAddressLink")
      website_s = (website ? website.content.strip : "-")

      csv << [id, name, phone_s, email_s, website_s, address_s]
      
    end


    next_link = doc.at_css("#link-page-next")
    pageNumber = (next_link ? pageNumber+1 : -1)

  end


end

