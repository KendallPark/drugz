require 'net/http'
require 'json'
require 'csv'
require 'yaml'
require 'json'

namespace :drugz do
  desc "TODO"
  task pull: :environment do
    worksheets_uri = URI('https://spreadsheets.google.com/feeds/worksheets/1UsK4glDU8dtE98fgoMg1TxNGJkYHuWiy3PtMrQqX3NI/public/values?alt=json')
    worksheets_json = JSON.parse(Net::HTTP.get(worksheets_uri))

    data = {}
    drugs = {}

    worksheets_json["feed"]["entry"].each do |sheet|
      title = sheet["title"]["$t"]
      next unless title =~ /Block [1-8]/
      sheet_uri = URI(sheet['link'][3]['href'])
      sheet_csv = Net::HTTP.get(sheet_uri).force_encoding(Encoding::UTF_8)
      data[title] = sheet_csv
      key = []
      csv = CSV.parse(sheet_csv)
      key = csv.first.map {|item| item.nil? ? "" : item.titleize }
      key[0] = "Case"
      drugs[title] = {}
      drugs[title]["key"] = key
      drugs[title]["drugs"] = {}
      csv.drop(1).each do |row|
        next unless row
        drug = row[1]
        drugs[title]["drugs"][drug] = {}
        drugs[title]["drugs"][drug]["Block"] = title.scan(/Block ([1-8])/)[0]
        row.each_with_index do |cell, i|
          next unless cell
          if i == 0
            cell = cell.scan(/[(C[0-8])\b*]+/)
          end
          drugs[title]["drugs"][drug][key[i]] = cell
        end
      end
    end

    # replaces blanks with previous blocks
    drugs.each do |block_name, value|
      key = value["key"]
      drugz = value["drugs"]
      drugz.each do |drug_name, drug_features|
        unless drug_features[key[2]]
          blocks_to_check = drugs.keys - [block_name]
          blocks_to_check.reverse.each do |b_name|
            if drugs[b_name]["drugs"][drug_name] && drugs[b_name]["drugs"][drug_name][key[2]]
              key.drop(2).each do |feature|
                drug_features[feature] = drugs[b_name]["drugs"][drug_name][feature] if drugs[b_name]["drugs"][drug_name][feature]
              end
            end
          end
        end
      end
    end

    File.open("#{File.dirname(File.dirname(File.dirname(__FILE__)))}/config/drugs.yml", 'w') { |f| f.write drugs.to_yaml }
  end

end
