#encoding: utf-8
if ENV["BONSAI_URL"]
# Elasticsearch::Model.client = Elasticsearch::Client.new({url: ENV['BONSAI_URL'], logs: true})
Searchkick.client = Elasticsearch::Client.new({url: ENV["BONSAI_URL"], logs: true})
end