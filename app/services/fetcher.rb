require 'net/http'

class Fetcher < Object

  cattr_accessor :base_url
  cattr_accessor :api_key

  def self.get_results(url)
    JSON.parse(Net::HTTP.get(URI.parse(url)))
  end

end
