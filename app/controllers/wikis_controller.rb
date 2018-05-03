require 'wikipedia'

class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    p q = params[:q] || 'Taiwan'
    str1_markerstring = '://'
    str2_markerstring = "."
    p base_url = request.base_url
    p sub_domain = base_url[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]

    p lang = sub_domain.blank? ? 'en' : sub_domain
    @lang = lang
    # lang = DetectLanguage.simple_detect(q)
    # lang = 'zh' if (lang == 'ja' || lang == 'zh-Hant' || lang == 'zh-Hans')

    wiki_data = wikir(q, lang)
    @summary = wiki_data.summary
    @fullurl = wiki_data.editurl
    @title = wiki_data.title

    unless params[:q]
      @u = 'WKM5jRAUgvU'
      @audio = 'wiki/Taiwan'
    else
      wiki = Wiki.find_by(title: q)
      if wiki.present?
        wiki.update(count: wiki.count+1)
        # @uwiki = wiki.u
        # (@audio = wiki.title) unless @uwiki
      else
        %x(sh bin/wiki "#{q}" "#{lang}")
        # YoutubeWorker.perform_async([q, lang])
        # @uwiki = %x(youtube-dl "ytsearch:#{q} on uWikipedia.org" --get-id)
        # TODO wiki = Wiki.create!(title: q, u: @uwiki)
        wiki = Wiki.create!(title: q)
      end
      @u = %x(youtube-dl "ytsearch:#{q} song" --get-id)
      wiki.videos.create!(yid: @u)
      @audio = q
    end
  end

  private

  def wikir title, lang
    Wikipedia.configure {
      domain "#{lang}.wikipedia.org"
      path   'w/api.php'
    }
    Wikipedia.find(title)
  end
end
