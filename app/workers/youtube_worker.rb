class YoutubeWorker
  include Sidekiq::Worker

  def perform(*args)
    q = args[0][0]
    lang = args[0][1]
    %x(sh bin/wiki "#{q}" "#{lang}")
  end
end
