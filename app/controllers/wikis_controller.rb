class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = params[:q]
    lang = DetectLanguage.simple_detect(q)
    lang = ( lang == 'ja' ? 'zh' : lang )
    unless q
      @u = '076Ag1ic-nM'
      @title = 'wiki/hi'
    else
      wiki = Wiki.find_by(title: q)

      if wiki
        wiki.update(count: wiki.count+1)
      else
        wiki = Wiki.create!(title: q, u: lang)
      end

      %x(sh bin/wiki "#{q}" "#{lang}")
      @u = %x(youtube-dl "ytsearch:#{q}" --get-id)
      wiki.videos.create(yid: @u)
      @title = wiki.title
    end
  end
end
