include SecQuery
require 'spec_helper'

describe SecQuery::Filing do

  let(:query){{
   name: "JOBS STEVEN P", :cik => "0001007844",
    relationships:[
      {cik: "0000320193", name: "APPLE INC"},
      {cik: "0001001039", name: "WALT DISNEY CO/"},
      {cik: "0001002114", name: "PIXAR \\CA\\"}
    ],
    transactions:[
      {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares:120000.0},
      {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
      {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
      {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
      {filing_number: "0001181431-06-028746", reporting_owner: "WALT DISNEY CO/", shares: 138000004.0},
      {filing_number: "0001356184-06-000008", reporting_owner: "PIXAR \\CA\\", shares: 60000002.0},
      {filing_number: "0001181431-06-019230", reporting_owner: "APPLE COMPUTER INC", shares: 4573553.0},
      {filing_number: "0001181431-06-028747", reporting_owner: "WALT DISNEY CO/", shares: 0.0}
    ],
    filings:[
      {cik: "0001007844", file_id: "0001181431-07-052839"},
      {cik: "0001007844", file_id: "0001356184-06-000008"},
      {cik: "0001007844", file_id: "0001193125-06-103741"},
      {cik: "0001007844", file_id: "0001181431-06-028747"},
      {cik: "0001007844", file_id: "0001181431-06-028746"},
      {cik: "0001007844", file_id: "0001181431-06-019230"},
      {cik: "0001007844", file_id: "0001193125-06-019727"},
      {cik: "0001007844", file_id: "0001104659-03-004723"}
    ]
  }}
  
  let(:entity) {SecQuery::Entity.find(query[:cik])}
  
  describe "Filings", vcr: { cassette_name: "Steve Jobs"} do
    it "should respond to filings" do
      entity.should respond_to(:filings)
      entity.filings.should be_kind_of(Array)
    end
    
    it "should be valid filing" do
      is_valid_filing?(entity.filings.first)
    end
    
    it "should respond to content" do
      entity.filings.first.should respond_to(:content)
      puts entity.filings.first.content
    end
  end
end
# describe "Relationships, Transactions and Filings" do
#   
#   ## Using Steve, because data should not change in the future. RIP.
#   
#   let(:jobs){{
#     first: "Steve", middle: "P", last: "Jobs", :cik => "0001007844",
#     relationships:[
#       {cik: "0000320193", name: "APPLE INC"},
#       {cik: "0001001039", name: "WALT DISNEY CO/"},
#       {cik: "0001002114", name: "PIXAR \\CA\\"}
#     ],
#     transactions:[
#       {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares:120000.0},
#       {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
#       {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
#       {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
#       {filing_number: "0001181431-06-028746", reporting_owner: "WALT DISNEY CO/", shares: 138000004.0},
#       {filing_number: "0001356184-06-000008", reporting_owner: "PIXAR \\CA\\", shares: 60000002.0},
#       {filing_number: "0001181431-06-019230", reporting_owner: "APPLE COMPUTER INC", shares: 4573553.0},
#       {filing_number: "0001181431-06-028747", reporting_owner: "WALT DISNEY CO/", shares: 0.0}
#     ],
#     filings:[
#       {cik: "0001007844", file_id: "0001181431-07-052839"},
#       {cik: "0001007844", file_id: "0001356184-06-000008"},
#       {cik: "0001007844", file_id: "0001193125-06-103741"},
#       {cik: "0001007844", file_id: "0001181431-06-028747"},
#       {cik: "0001007844", file_id: "0001181431-06-028746"},
#       {cik: "0001007844", file_id: "0001181431-06-019230"},
#       {cik: "0001007844", file_id: "0001193125-06-019727"},
#       {cik: "0001007844", file_id: "0001104659-03-004723"}
#     ]
#   }}
  
  # let(:entity) {SecQuery::Entity.find({:first=> "Steve",  middle: "P", last: "Jobs", :cik => "0001007844"}, true)}
  # 
  # context "when quering entities with option 'true'" do
  #   it "should provide relationships" do
  #     entity.relationships.each_with_index do |r, i|
  #       r.cik.should eql(jobs[:relationships][i][:cik])
  #     end
  #   end
  #   it "should provide transactions" do
  #     entity.transactions.each_with_index do |t, i|
  #       t.filing_number.should eql(jobs[:transactions][i][:filing_number])
  #     end
  #   end
  #   it "should provide filings" do
  #     entity.filings.each_with_index do |f, i|
  #       f.file_id.should eql(jobs[:filings][i][:file_id])
  #     end
  #   end
  # end
#end