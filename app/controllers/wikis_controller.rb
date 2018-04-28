class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = params[:q]
    video = Wiki.find_by(title: q)
    if video
      @u = video.u
      video.update(count: video.count+1)
    else
      %x(sh bin/wiki "#{q}")
      u = %x(youtube-dl "ytsearch:#{q}" --get-id)
      video = Wiki.create!(title: q, u: u)
      @u = u
    end
    @title = video.title
  end
end
