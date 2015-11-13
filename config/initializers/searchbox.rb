#encoding: utf-8
if ENV["SEARCHBOX_URL"]
	Searchkick.client = Elasticsearch::Client.new({url: ENV['SEARCHBOX_URL'], logs: true})
end