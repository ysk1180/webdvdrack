class PostsController < ApplicationController
  def new
    @h = params[:h]
    @h_post = Post.find_by(h: @h) if @h.present?
    @h = nil if @h_post.nil?
    @posts = Post.last(5).reverse
    @count = Post.all.count
    if @h_post.present?
      posts = same_movies(@h_post)
      @same_movie_posts = posts.uniq.shuffle!.last(5)
    end
  end

  def search
    contents = { content: render_to_string(partial: 'posts/items.html.erb', locals: {dvds: search_by_amazon(params[:keyword]), index_number: params[:index]}) }
    render json: contents
  end

  def make
    generate(to_uploaded(params[:imgData]), params[:hash])
    movie1 = ''
    movie2 = ''
    movie3 =''
    post = ''
    ActiveRecord::Base.transaction do
      movie1 = Movie.find_or_create_by(title: params[:title1], url: params[:url1], image: params[:image1])
      movie2 = Movie.find_or_create_by(title: params[:title2], url: params[:url2], image: params[:image2]) if params[:title2].present?
      movie3 = Movie.find_or_create_by(title: params[:title3], url: params[:url3], image: params[:image3]) if params[:title3].present?
      post = Post.create!(title: params[:title], name: params[:name], twitter_id: params[:twitter_id], h: params[:hash])
      PostMovie.create!(post_id: post.id, movie_id: movie1.id)
      PostMovie.create!(post_id: post.id, movie_id: movie2.id) if params[:title2].present?
      PostMovie.create!(post_id: post.id, movie_id: movie3.id) if params[:title3].present?
    end
    same_movies_count = same_movies(post).count
    data = [same_movies_count]
    render :json => data
  end

  def index
    @posts = Post.all.order('created_at desc').page(params[:page]).per(20)
    @count = Post.all.count
  end

  private

  def same_movies(post)
    posts = []
    movies = post.movies
    posts.concat(movies[0].posts)
    posts.concat(movies[1].posts) if movies[1].present?
    posts.concat(movies[2].posts) if movies[2].present?
    posts.delete(post)
    posts
  end

  def search_by_amazon(keyword)
    # デバッグ出力用/trueで出力
    Amazon::Ecs.debug = false

    # AmazonAPIで検索
    results = Amazon::Ecs.item_search(
      keyword,
      search_index:  'DVD',
      dataType: 'script',
      response_group: 'ItemAttributes, Images',
      country:  'jp',
    )

    # 検索結果から本のタイトル,画像URL, 詳細ページURLの取得
    dvds = []
    results.items.each do |item|
      next if adult?(item)
      dvd = {
        title: item.get('ItemAttributes/Title'),
        image: item.get('LargeImage/URL'),
        url: item.get('DetailPageURL'),
      }
      dvds << dvd
    end
    dvds
  end

  def adult?(item)
    item.get('ItemAttributes/IsAdultProduct') == '1'
  end

  def to_uploaded(base64_param)
    content_type, string_data = base64_param.match(/data:(.*?);(?:.*?),(.*)$/).captures
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile << Base64.decode64(string_data)
    file_param = { type: content_type, tempfile: tempfile }
    ActionDispatch::Http::UploadedFile.new(file_param)
  end

  # S3 Bucket 内に画像を作成
  def generate(image_uri, hash)
    bucket.files.create(key: png_path_generate(hash), public: true, body: image_uri)
  end

  # pngイメージのPATHを作成する
  def png_path_generate(hash)
    "images/#{hash}.png"
  end

  # bucket名を取得する
  def bucket
    # production / development / test
    environment = Rails.env
    storage.directories.get("webdvdrack-#{environment}")
  end

  # storageを生成する
  def storage
    Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID_S3'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY_S3'],
      region: 'ap-northeast-1'
    )
  end
end
