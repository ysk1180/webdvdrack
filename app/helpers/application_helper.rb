module ApplicationHelper
  def get_twitter_card_info(h)
    twitter_card = {}
    if h.present?
      twitter_card[:url] = "https://moviesharesns.herokuapp.com/?h=#{h}"
      twitter_card[:image] = "https://s3-ap-northeast-1.amazonaws.com/webdvdrack-production/images/#{h}.png"
      name = Post.find_by(h: h).name
      name = name.present? ? name : '名無し'
      twitter_card[:title] = "#{name}さんがシェアした映画"
    else
      twitter_card[:url] = 'https://moviesharesns.herokuapp.com/'
      twitter_card[:image] = 'https://s3-ap-northeast-1.amazonaws.com/webdvdrack-production/images/dce74ty4.png'
      twitter_card[:title] = '映画シェア'
    end
    twitter_card[:card] = 'summary_large_image'
    twitter_card[:description] = 'お気に入りの映画をシェアできます'
    twitter_card
  end
end
