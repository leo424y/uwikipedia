class WikisController < ApplicationController
  def show
    q = params[:q]
    video = Wiki.find_by(title: q)
    if video
      @u = video.u
      video.update(count: video.count+1)
    else
      u = %x(youtube-dl "ytsearch:#{q}" --get-id)
      p u
      Wiki.create(title: q, u: u)
      @u = u
    end
  end
end
