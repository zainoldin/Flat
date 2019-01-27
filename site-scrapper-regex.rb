require 'HTTParty'
require 'Nokogiri'
require "csv"

class Scrapper

attr_accessor :parse_page

    def initialize
        doc = HTTParty.get("https://krisha.kz/prodazha/kvartiry/?das[price][from]=100000000&das[price][to]=100000000")
        @parse_page ||= Nokogiri::HTML(doc)
    end
    
    def item_container
        parse_page.css(".a-card__main-info")
    end

    def get_desc
        item_container.css(".a-card__header-left a").map { |anchor| anchor}
    end

    def filter_data_by_regex
        desc = get_desc
        header_info = []
        
        (0...desc.size).each do |index| 
            variable = "#{desc[index]}"
            # get only main details of apartment from krisha.kz like "5-комнатная квартира, 256 м², 2/3 эт."
            regex = /[0-9]-([\u0401\u0451\u0410-\u044f])*\s([\u0401\u0451\u0410-\u044f])*,\s([0-9])*(.)*([0-9]*)\sм²,\s([0-9])+.([0-9])+\s[\u0401\u0451\u0410-\u044f][\u0401\u0451\u0410-\u044f]./
            match = variable.match(regex)
            
            if match 
                header_info.push(match)
            end
        end
        return header_info
    end  
    
    def print_fetched_info(fetched_info)
        (0...fetched_info.size).each do |index|
            puts fetched_info[index]
        end
    end

    def save_to_csv_file(info)
        CSV.open("result.csv", "wb") do |csv|
            csv << info
        end
    end
    
    scrapper = Scrapper.new
    header_info = scrapper.filter_data_by_regex
    scrapper.print_fetched_info(header_info)
    scrapper.save_to_csv_file(header_info)

end 