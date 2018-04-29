class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = ZhConv.convert("zh-cn", params[:q])
    lang = DetectLanguage.simple_detect(q)
    lang = 'zh' if (lang == ('ja' || 'zh-hant' || 'zh-hans'))

    unless q
      @u = '076Ag1ic-nM'
      @title = 'wiki/hi'
    else
      wiki = Wiki.find_by(title: q)

      if wiki
        wiki.update(count: wiki.count+1)
      else
        wiki = Wiki.create!(title: q, u: lang)
        %x(sh bin/wiki "#{q}" "#{lang}")
      end
      @u = %x(youtube-dl "ytsearch:#{q}" --get-id)
      @title = wiki.title
      wiki.videos.create(yid: @u)
    end
  end
end
