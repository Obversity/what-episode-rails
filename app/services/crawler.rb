require 'open-uri'

class Crawler < Object

  cattr_accessor :base_url

  self.base_url = "http://www.imdb.com"

  class << self

    def get_shows
      # list view of top 250 shows
      url = "#{base_url}/list/ls051600015/?start=1&view=compact&sort=listorian:asc&defaults=1&scb=0.19763910689993835"
      doc = Nokogiri::HTML(open(url))
      show_links = doc.css('.list_item[data-item-id]>td.title>a')

      show_links.each do |link|
        title = link.children.first.text
        path    = link['href'] # "/title/tt0141842/"
        imdb_id = path.split('/').last
        show = Show.find_or_initialize_by(title: title)
        show.imdb_id = imdb_id
        show.save
      end
    end

    def get_episodes_for_show(show)
      # http://www.imdb.com/title/tt0141842
      url = "#{base_url}/title/#{show.imdb_id}/episodes"
      doc = Nokogiri::HTML(open(url))
      seasons = doc.css('#bySeason>option').map{ |option| option["value"] }
      seasons.each do |n|
        season = show.seasons.find_or_initialize_by(number: n)
        season.save

        season_url = "#{url}?season=#{n}"
        season_doc = Nokogiri::HTML(open(season_url))

        episode_infos = season_doc.css('.eplist>.list_item>.info')
        episode_infos.each do |info|

          episode_number = info.at_css('meta[itemprop="episodeNumber"]')["content"]
          link    = info.at_css('strong>a')
          title   = link["title"]
          path    = link["href"]
          imdb_id = path.split('/').reject(&:blank?).second

          episode = season.episodes.find_or_initialize_by(number: episode_number)
          episode.attributes = { title: title, imdb_id: imdb_id }
          episode.save
        end
      end
    end

  end
end
