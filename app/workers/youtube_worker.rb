class YoutubeWorker
  include Sidekiq::Worker

  def perform(*args)
    title = args[0][0]
  end
end
