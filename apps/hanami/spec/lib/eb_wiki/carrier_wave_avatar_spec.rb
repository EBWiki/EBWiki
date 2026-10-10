# frozen_string_literal: true

require "tempfile"
require "eb_wiki/carrier_wave_avatar"

RSpec.describe EbWiki::CarrierWaveAvatar do
  let(:png) do
    ["89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c489" \
     "0000000a49444154789c63000100000500010d0a2db40000000049454e44ae426082"].pack("H*")
  end

  it "uses CarrierWave object keys for the original and every version" do
    keys = described_class.object_keys(42, "scott.jpg")
    expect(keys[:original]).to eq("uploads/case/avatar/42/scott.jpg")
    expect(keys["large_avatar"]).to eq("uploads/case/avatar/42/large_avatar_scott.jpg")
    expect(keys["medium_avatar"]).to eq("uploads/case/avatar/42/medium_avatar_scott.jpg")
    expect(keys["small_avatar"]).to eq("uploads/case/avatar/42/small_avatar_scott.jpg")
    expect(keys["thumb"]).to eq("uploads/case/avatar/42/thumb_scott.jpg")
  end

  it "writes those keys under the local upload root when S3 is not configured" do
    Dir.mktmpdir do |dir|
      ENV["LOCAL_UPLOAD_ROOT"] = dir
      record = Struct.new(:id).new(7)
      upload = {filename: "portrait.png", tempfile: Tempfile.new(["portrait", ".png"])}
      File.binwrite(upload[:tempfile].path, png)

      stored = described_class.store(record: record, upload: upload)
      expect(stored[:filename]).to eq("portrait.png")
      expect(stored[:default_avatar_url]).to eq("/uploads/case/avatar/7/portrait.png")
      described_class.object_keys(7, "portrait.png").each_value do |key|
        expect(File.file?(File.join(dir, key))).to be(true)
      end
    ensure
      ENV.delete("LOCAL_UPLOAD_ROOT")
    end
  end

  it "rejects a path-escaping filename" do
    record = Struct.new(:id).new(1)
    upload = {filename: "../secret.jpg", tempfile: Tempfile.new("x")}
    expect(described_class.store(record: record, upload: upload)).to be_nil
  end
end
