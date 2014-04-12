# encoding: UTF-8

module SecQuery
  # => SecQuery::Filing
  # SecQuery::Filing requests and parses filings for any given SecQuery::Entity
  class Filing
    attr_accessor :cik, :accession_nunber, :act, :file_number,
                  :file_number_href, :filing_date, :filing_href,
                  :filing_type, :film_number, :form_name, :size, :type

    def initialize(cik, filing)
      @cik = cik
      filing.each do |key, value|
        instance_variable_set "@#{key}", value.to_s
      end
    end

    def filing_url
      response = Entity.query(filing_href)
      document = Nokogiri::HTML(response)
      document.xpath('//table/tr/td/a').map do |link|
        link['href'] unless link['href'].match('.txt')
      end.compact
    end

    def content(content = [])
      response = Entity.query("http://www.sec.gov/#{filing_url.first}")
      document = Nokogiri::HTML(response)
      if document.xpath('//document').to_s.length > 0
        document.xpath('//document').each do |e|
          content << Hashie::Mash.new(Crack::XML.parse(e.to_s)['document'])
        end
      end
      content
    end

    def self.find(cik, start = 0, count = 80)
      browse_edgar = 'http://www.sec.gov/cgi-bin/browse-edgar?'
      params = "action=getcompany&CIK=#{cik}&count=#{count}&start=#{start}"
      response = Entity.query("#{browse_edgar}#{params}&output=atom")
      document = Nokogiri::HTML(response)
      parse(cik, document)
    end

    def self.parse(cik, document)
      filings = []
      if document.xpath('//content').to_s.length > 0
        document.xpath('//content').each do |e|
          if e.xpath('//content/accession-nunber').to_s.length > 0
            filings << Filing.new(cik, Crack::XML.parse(e.to_s)['content'])
          end
        end
      end
      filings
    end
  end
end
