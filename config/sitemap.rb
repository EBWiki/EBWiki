# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://ebwiki.org"

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.create_index = true

if Rails.env.production?
# Instance of `SitemapGenerator::s3Adapter -- could have used wave adapter instead
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
    fog_provider: 'AWS',
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_KEY_ID'],
    fog_directory: ENV['FOG_DIRECTORY'],
    fog_region: ENV['S3_REGION'])

# The remote host where your sitemaps will be hosted
  SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"
end

SitemapGenerator::Sitemap.create do
  # Add all articles:

  Article.find_each do |article|
    add article_path(article), lastmod: article.updated_at
    add articles_followers_path(article), lastmod: article.updated_at
  end
end

SitemapGenerator::Sitemap.filename = 'agencies'
SitemapGenerator::Sitemap.create do
  # Add all agencies:

  Agency.find_each do |agency|
    add agency_path(agency), lastmod: agency.updated_at
  end

  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: priority: 0.5, changefreq: 'weekly',
  #           lastmod: Time.now, host: default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, priority: 0.7, changefreq: 'daily'
  #

end
