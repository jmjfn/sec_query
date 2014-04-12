module SecQuery
  class Filing
    attr_accessor :cik, :accession_nunber, :act, :file_number, :file_number_href, :filing_date, :filing_href, :filing_type, :film_number, :form_name, :size, :type

    def initialize(cik, filing)
      @cik = cik
      filing.each do |key, value|
        instance_variable_set "@#{key}", value.to_s
      end
    end

    def content
      unless filing_href.nil?
        response = Entity.query(filing_href)
        document = Nokogiri::HTML(response)
        url = document.xpath('//table/tr/td/a').map { |link| link['href'] if !!(link['href'].match(".txt"))}.compact
        unless url.empty?
          response = Entity.query("http://www.sec.gov/#{url.first}")
          document = Nokogiri::HTML(response)

          content = []
          if document.xpath('//document').to_s.length > 0
            document.xpath('//document').each do |e|
              content << Hashie::Mash.new(Crack::XML.parse(e.to_s)['document'])
            end
          end
          return content
        end
      end
      return nil
    end

    def self.find(cik, start=0, count=80)
      url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{cik}&count=#{count}&start=#{start}"
      response = Entity.query(url+"&output=atom")
      document = Nokogiri::HTML(response)
      filings = []
      if document.xpath('//content').to_s.length > 0
        document.xpath('//content').each do |e|
          if e.xpath('//content/accession-nunber').to_s.length > 0
            filings << Filing.new(cik, Crack::XML.parse(e.to_s)['content'])
          end
        end
      end
      return filings
    end
  end
end
