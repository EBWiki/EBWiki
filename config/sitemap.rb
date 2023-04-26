# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://ebwiki.org'

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.create_index = true

if Rails.env.production?
  # Instance of `SitemapGenerator::s3Adapter -- could have used wave adapter instead
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
    fog_provider: 'AWS',
    aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
    aws_secret_access_key: ENV.fetch('AWS_SECRET_KEY_ID', nil),
    fog_directory: ENV.fetch('FOG_DIRECTORY', nil),
    fog_region: ENV.fetch('S3_REGION', nil)
  )

  # The remote host where your sitemaps will be hosted
  SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV.fetch('FOG_DIRECTORY',
                                                                nil)}.s3.amazonaws.com/"
end

SitemapGenerator::Sitemap.create do
  # Add all cases:
  Case.find_each do |this_case|
    add case_path(this_case), lastmod: this_case.updated_at
    add cases_followers_path(this_case), lastmod: this_case.updated_at
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
  # Add '/cases'
  #
  #   add cases_path, priority: 0.7, changefreq: 'daily'
  #
end
