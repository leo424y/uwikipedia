require 'wikipedia'

class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    p q = params[:q] || 'Taiwan'
    p sub_domain = request.base_url.split('http://')[1].split('.')[0]
    all_lang = %w(de en es fr it ja pl pt ru zh)
    p lang = (all_lang.include?(sub_domain) ? sub_domain : 'en')
    @lang = lang
    # lang = DetectLanguage.simple_detect(q)
    # lang = 'zh' if (lang == 'ja' || lang == 'zh-Hant' || lang == 'zh-Hans')

    wiki_data = wikir(q, lang)

    if (q == 'cofacts')
      @summary = '此訊息中所附影片已經被原上傳者下架，且偽造中央社新聞片頭。鉀-40屬天然放射性核種，廣泛存在於農漁產品，人體中也有一定數量的鉀-40。且WHO世界衛生組織、英國衛生部針對鉀攝取建議中提到，基於健康因素，建議成人每日適當攝取約3.5克的鉀，美國國家醫學院則建議鉀攝取4.7克，以維持健康'
      @fullurl = 'https://cofacts.g0v.tw/article/3lrautersil4z'
      @editurl = 'https://cofacts.g0v.tw/reply/JhSq2GIBD3gUWf_HaVvv'
      @title = '大家要自求多福了！最好不吃含有氯化鉀的食品！台鹽 居然成殺手鹽？！請詳細看完…一起關心自己和家人的健康。'
      @u = 'BM1z1_PTl9Q'
      @audio = 'en/cofacts'
    elsif (q == 'join')
      @summary = '參照<世界衛生組織脊骨神經醫學基礎培訓和安全性指南>成立脊骨神經醫學系，並參照美、加、英、澳等先進國家建立脊骨神經醫學制度(立法)，讓台灣可以培養出符合國際教育水準的脊骨神經醫師(Doctor of Chiropractic)，來服務台灣民眾(1)；同時就加拿大及美國針對脊骨神經醫學能有效降地整體醫療支出之研究進行深入之探討，以期將來能達到節省全民健康保險醫療費用之支出。'
      @fullurl = 'https://join.gov.tw/idea/detail/e9758e8a-98a2-4903-ae4d-3be9a4970890'
      @editurl = 'https://join.gov.tw/idea/detail/e9758e8a-98a2-4903-ae4d-3be9a4970890'
      @title = '參照<世界衛生組織脊骨神經醫學基礎培訓和安全性指南>成立脊骨神經醫學系,建立脊骨神經醫學制度法規'
      @u = 'BJQfT9C5Adc'
      @audio = 'en/join'
    else
      @summary = wiki_data.summary
      @editurl = wiki_data.editurl
      @fullurl = wiki_data.fullurl
      @title = wiki_data.title

      unless params[:q]
        @u = 'WKM5jRAUgvU'
        @audio = 'wiki/en/Taiwan'
      else
        wiki = Wiki.find_by(title: q, lang: lang)
        if wiki.present?
          wiki.update(count: wiki.count+1)
          # @uwiki = wiki.u
          # (@audio = wiki.title) unless @uwiki
        else
          %x(sh bin/wiki "#{q}" "#{lang}")
          # YoutubeWorker.perform_async([q, lang])
          # @uwiki = %x(youtube-dl "ytsearch:#{q} on uWikipedia.org" --get-id)
          # TODO wiki = Wiki.create!(title: q, u: @uwiki)
          wiki = Wiki.create!(title: q, lang: lang)
        end
        @u = %x(youtube-dl "ytsearch:#{q} song" --get-id)
        wiki.videos.create!(yid: @u)
        @audio = "#{lang}/#{q}"
      end
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
