require 'wikipedia'

class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = params[:q]

    unless q
      lang = 'en'
      @title = 'Taiwan'
      @u = 'WKM5jRAUgvU'
      @audio = 'wiki/Taiwan'
    else
      @title = q
      lang = DetectLanguage.simple_detect(q)
      (lang = 'zh') if (lang == 'ja' || lang == 'zh-Hant' || lang == 'zh-Hans')

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
      @audio = @title
    end
    
    wiki_data = wikir(@title, lang)
    @summary = wiki_data.summary
    @fullurl = wiki_data.fullurl
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
