class OmdbFetcher < Fetcher

  self.base_url = "http://www.omdbapi.com"
  self.api_key = Figaro.env.omdb_api_key

  def self.fetch(query)
    query_url = "#{base_url}?t=#{query}&type=series&apikey=#{api_key}"
    result    = get_results(query_url)

    unless result["Response"] == "False"
      total_seasons = result["totalSeasons"].to_i
      if total_seasons > 0
        show          = Show.find_or_initialize_by(title: result["Title"])
        imdb_id       = result["imdbID"]
        total_seasons = result["totalSeasons"].to_i
        show.attributes = {
          year:  result["Year"],
          genre: result["Genre"],
          image: result["Poster"],
        }

        total_seasons.times do |i|
          query_url     = "#{base_url}?t=#{imdb_id}&Season=#{i+1}&plot=short&apikey=#{api_key}"
          season_result = get_results(query_url)
          season        = show.seasons.find_or_initialize_by(number: season_result["Season"].to_i)

          season_result["Episodes"].each do |episode_result|
            episode      = season.episodes.find_or_initialize_by(number: episode_result["Episode"])
            release_date = Date.parse(episode_result["Released"]) rescue nil
            episode.attributes = {
              title:       episode_result["Title"],
              released:    release_date,
              number:      episode_result["Episode"],
              imdb_rating: episode_result["imdbRating"],
              imdb_id:     episode_result["imdbID"],
            }
            episode.save
            self.delay.fetch_episode(episode.imdb_id) if episode.plot.blank?
          end
          season.save
        end
        show.save
        return [show]
      end
    end
  end

  def self.fetch_episode(imdb_id)
    query_url = "#{base_url}?i=#{imdb_id}&plot=short&apikey=#{api_key}"
    episode_result = get_results(query_url)
    Episode
      .find_by(imdb_id: imdb_id)
      .update(plot: episode_result["Plot"], image_url: episode_result["Poster"])
  end

end
