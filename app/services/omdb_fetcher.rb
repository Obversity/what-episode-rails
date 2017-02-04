class OmdbFetcher < Fetcher

  self.base_url = "http://www.omdbapi.com"

  def self.fetch(query)
    query_url = "#{base_url}?t=#{query}"
    result = get_results(query_url)
    unless result["Response"] == "False"
      if result["Type"] == "series"
        show = Show.find_or_initialize_by(title: result["Title"])
        show.attributes = {
          year: result["Year"],
          genre: result["Genre"],
          image: result["Poster"],
        }
        imdb_id = result["imdbID"]
        total_seasons = result["totalSeasons"].to_i
        total_seasons.times do |i|
          query_url = "#{base_url}?t=#{imdb_id}&Season=#{i+1}"
          season_result = get_results(query_url)
          season = show.seasons.find_or_initialize_by(number: season_result["Season"].to_i)
          season_result["Episodes"].each do |episode_result|
            episode = season.episodes.find_or_initialize_by(number: episode_result["Episode"])
            release_date = Date.parse(episode_result["Released"]) rescue nil
            episode.attributes = {
              title: episode_result["Title"],
              released: release_date,
              number: episode_result["Episode"],
              imdb_rating: episode_result["imdbRating"],
              imdb_id: episode_result["imdbID"],
            }
            episode.save
          end
          season.save
        end
        show.save
        return [show]
      end
    end
  end

end
