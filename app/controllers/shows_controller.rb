class ShowsController < ApplicationController

  def index
    # ensure nginx caches results for 2 minutes in case of high load
    expires_in 2.minutes

    query = params[:search]
    @shows = Show.search(query)
    if @shows.none?
      OmdbFetcher.fetch(query)
      @shows = Show.search(query)
    end
    @show = @shows.first
    if @show.present?
      render json: @show.as_json(include:
        { seasons: { include: { episodes: { include: :questions } } }, }
      ), status: :ok
    else
      render json: { errors: ["Show not found"] }, status: 404
    end
  end

  def shows_list
    render json: Show.pluck(:title)
  end


end
