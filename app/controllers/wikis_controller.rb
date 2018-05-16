require 'wikipedia'

class WikisController < ApplicationController
  def show
    response.headers.delete('X-Frame-Options')
    q = params[:q] || 'Taiwan'
    @sub_domain = request.base_url.split('http://')[1].split('.')[0]
    (@sub_domain = 'en') if (@sub_domain == 'localhost:3000')
    @all_lang = %w(de en es fr it ja pl pt ru zh)
    @all_lang_wiki = %w(de en es fr it ja pl pt ru zh simple)
    lang = (@all_lang.include?(@sub_domain) ? @sub_domain : 'en')
    @lang = lang
    # lang = DetectLanguage.simple_detect(q)
    # lang = 'zh' if (lang == 'ja' || lang == 'zh-Hant' || lang == 'zh-Hans')

    wiki_data = wikir(q, @sub_domain)

    if (q == 'cofacts')
      @summary = '此訊息中所附影片已經被原上傳者下架，且偽造中央社新聞片頭。鉀-40屬天然放射性核種，廣泛存在於農漁產品，人體中也有一定數量的鉀-40。且WHO世界衛生組織、英國衛生部針對鉀攝取建議中提到，基於健康因素，建議成人每日適當攝取約3.5克的鉀，美國國家醫學院則建議鉀攝取4.7克，以維持健康'
      @fullurl = 'https://cofacts.g0v.tw/article/3lrautersil4z'
      @editurl = 'https://cofacts.g0v.tw/reply/JhSq2GIBD3gUWf_HaVvv'
      @title = '大家要自求多福了！最好不吃含有氯化鉀的食品！台鹽 居然成殺手鹽？！請詳細看完…一起關心自己和家人的健康。'
      @u = 'BM1z1_PTl9Q'
      @audio = 'en/cofacts'
    elsif (q == 'join')
      @summary = '脊骨神經醫學已是世界衛生組織認可的醫療專業,台灣沒有理由不支持這項專業.脊骨神經醫學已是世界衛生組織認可的專業,台灣沒沒有理由阻止這項在國外學習的好方式幫助台灣人民.歐美國家醫學比台灣先進都有脊骨神經科醫師,台灣政府應該開放脊骨神經科進來,跟上歐美國家.台灣醫學進步,為何無脊骨神經專科及相關法規?現代人長時間使用手機等,衍生出的病變更需要有脊骨神經專科的照護!脊骨神經醫學帶給我希望的曙光.台灣需要與WHO同步,台灣需要這一個專業醫學!'
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
      @langlinks = wiki_data.langlinks
      unless params[:q]
        @u = 'WKM5jRAUgvU'
        @audio = 'wiki/en/Taiwan'
      else
        wiki = Wiki.find_by(title: @title, lang: @sub_domain)
        @audio = "#{@sub_domain}/#{@title}"
        if wiki.present?
          @u = wiki.videos.last.yid
          wiki.update(count: wiki.count+1)
          # @uwiki = wiki.u
          # (@audio = wiki.title) unless @uwiki
        elsif @summary.present?
          @u = %x(youtube-dl "ytsearch:#{@title} #{lang}" --get-id)
          File.open(@title, "w") {|f| f.write( ttsfy(@summary, lang) ) }
          %x(gtts-cli -f "#{@title}" -l "#{lang}" -o "./public/wiki/#{@sub_domain}/#{@title}.mp3";)
          FileUtils.rm(@title)
          # %x(sh bin/wiki "#{q}" "#{lang}")
          # YoutubeWorker.perform_async([q, lang])
          # @uwiki = %x(youtube-dl "ytsearch:#{q} on uWikipedia.org" --get-id)
          # TODO wiki = Wiki.create!(title: q, u: @uwiki)
          wiki = Wiki.create!(title: @title, lang: @sub_domain)
          wiki.videos.create!(yid: @u)
        end
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

  def ttsfy content, lang
    zh_lang = %w(ja zh)
    en_lang = %w(de en es fr it pl pt ru)
    c=[]

    if zh_lang.include?(lang)
      b=content.split(/[（）]/)
    elsif en_lang.include?(lang)
      b=content.split(/[()]/)
    end

    b.each_with_index {|b,i| c << b if i%2==0}

    if zh_lang.include?(lang)
      result = c.join.sub('  ', ' ').sub('。', '，')
    elsif en_lang.include?(lang)
      result = c.join.sub('  ', ' ').sub('e.g.', 'such as').sub(',000', '000')
    end

    result
  end
end
