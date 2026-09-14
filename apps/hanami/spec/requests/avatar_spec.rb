# frozen_string_literal: true

require "rack/test"
require "tmpdir"

RSpec.describe "Case avatar uploads", :db, type: :request do
  let(:png) do
    ["89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c489" \
     "0000000a49444154789c63000100000500010d0a2db40000000049454e44ae426082"].pack("H*")
  end

  def uploaded_png
    path = File.join(Dir.tmpdir, "scott.png")
    File.binwrite(path, png)
    Rack::Test::UploadedFile.new(path, "image/png")
  end

  it "stores a new case photo on CarrierWave keys and shows the large version" do
    Dir.mktmpdir do |dir|
      ENV["LOCAL_UPLOAD_ROOT"] = dir
      TestData.insert_user(email: "editor@example.com", password: "password123")
      state_id = TestData.insert_state
      agency_id = TestData.insert_agency

      post "/login", email: "editor@example.com", password: "password123"
      post "/cases", {
        case: {
          title: "Photo Case",
          date: "2016-01-02",
          city: "Chicago",
          state_id: state_id,
          overview: "<p>Overview</p>",
          blurb: "Blurb",
          summary: "Added a photo",
          cause_of_death: "shooting",
          subjects: [{name: "Test Subject", age: "22"}],
          links: [{url: "", title: ""}],
          agency_ids: [agency_id],
          avatar: uploaded_png
        }
      }

      expect(last_response.status).to eq(302)
      record = TestData.relations[:cases].where(slug: "photo-case").one
      expect(record[:avatar]).to eq("scott.png")
      expect(record[:default_avatar_url]).to eq("/uploads/case/avatar/#{record[:id]}/scott.png")
      expect(File.file?(File.join(dir, "uploads/case/avatar/#{record[:id]}/large_avatar_scott.png"))).to be(true)

      get "/cases/photo-case"
      expect(last_response.body).to include("/uploads/case/avatar/#{record[:id]}/scott.png")
    ensure
      ENV.delete("LOCAL_UPLOAD_ROOT")
    end
  end
end
