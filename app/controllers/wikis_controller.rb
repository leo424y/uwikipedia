require 'wikipedia'

class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = params[:q]

    unless q
      lang = 'en'
      wiki = Wiki.find_by(title: 'Taiwan')
      @u = 'WKM5jRAUgvU'
      @audio = 'Taiwan'
      @autoplay = '1'
    else
      lang = DetectLanguage.simple_detect(q)
      (lang = 'zh') if (lang == 'ja' || lang == 'zh-Hant' || lang == 'zh-Hans')

      wiki = Wiki.find_by(title: q)

      if wiki.present?
        wiki.update(count: wiki.count+1)
        @u = wiki.videos.last.yid
        @audio = wiki.title
        @autoplay = '0'
      else
        wiki = Wiki.create!(title: q, u: lang)
        # %x(sh bin/wiki "#{q}" "#{lang}")
        YoutubeWorker.perform_async([q, lang])
        @u = %x(youtube-dl "ytsearch:#{q} on uWikipedia.org" --get-id)
        @autoplay = '1'
      end
      wiki.videos.create!(yid: @u)
    end
    @title = wiki.title
    wiki_data = wikir(wiki.title, lang)
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
