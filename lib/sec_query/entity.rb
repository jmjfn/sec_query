module SecQuery
  class Entity
    attr_accessor :cik, :name, :mailing_address, :business_address, :company_info
    
    def initialize(company_info)
      @company_info = Hashie::Mash.new(company_info)
      @cik = @company_info.cik
      @name = @company_info.conformed_name
      @company_info.addresses.address.each do |address|
        instance_variable_set "@#{address.type}_address", address
      end
    end

    def filings
      Filing.find(@cik)
    end

    def self.query(url)
      RestClient.get(url){ |response, request, result, &block|
        case response.code
          when 200
          return response
          else
          response.return!(request, result, &block)
        end
      }
    end
    
    def self.format_params(args)
      if args.is_a?(String)
        if args.length == 10 && Float(args)
          args = { cik: args }
        elsif args.length == 4
          args = { symbol: args }
        else
          args = { name: args }
        end
      end
      if args[:symbol] != nil
        string = "CIK="+args[:symbol]
      elsif args[:cik] != nil
        string = "CIK="+args[:cik]
      elsif args[:first] != nil and args[:last] != nil
        string = "company="+args[:last]+" "+args[:first]
      elsif args[:name] != nil
        string = "company="+args[:name].gsub(/[(,?!\''"":.)]/, '')
      end
      return string.to_s.gsub(" ", "+")
    end

    def self.url(params)
      return "http://www.sec.gov/cgi-bin/browse-edgar?#{params}&action=getcompany"
    end

    def self.find(entity_args)
      url = Entity.url(Entity.format_params(entity_args))

      response = Entity.query(url+"&output=atom")
      document = Nokogiri::HTML(response)

      if document.xpath('//feed/company-info').to_s.length > 0
        company_info = Crack::XML.parse(document.xpath('//feed/company-info').to_s)['company_info']
      elsif document.xpath('//feed/entry/content/company-info').to_s.length > 0
        company_info = Crack::XML.parse(document.xpath('//content/company-info').to_s)['company_info']
      end

      unless company_info
        return nil
      else
        return Entity.new(company_info)
      end
    end
  end
end