# require 'rails_helper'
# require 'carrierwave/test/matchers'

# describe AvatarUploader do
#   include CarrierWave::Test::Matchers

#   # Enable images processing before executing the examples
#   before(:all) do
#     AvatarUploader.enable_processing = true
#   end

#   # Create a new uploader. The model is mocked as the uploading and resizing images does not depend on the model creation.
#   before(:each) do
#     @uploader = AvatarUploader.new(mock_model(Article).as_null_object)
#     @uploader.store!(File.open(path_to_file))
#   end

#   # Disable images processing after executing the examples
#   after(:all) do
#     AvatarUploader.enable_processing = false
#   end

#   # Testing whether image is no larger than given dimensions
#   context 'the default version' do
#     it 'scales down an image to be no larger than 250 by 250 pixels' do
#       @uploader.should be_no_larger_than(250, 250)
#     end
#   end

#   # Testing whether image has the exact dimensions
#   context 'the thumb version' do
#     it 'scales down an image to be exactly 50 by 50 pixels' do
#       @uploader.thumb.should have_dimensions(50, 50)
#     end
#   end
# end
# # require 'carrierwave/test/matchers'

# # describe AvatarUploader do
# #   include CarrierWave::Test::Matchers

# #   let(:article) { double('article') }
# #   let(:uploader) { AvatarUploader.new(article, :avatar) }

# #   # Enable images processing before executing the examples
# #   before(:all) do
# #     AvatarUploader.enable_processing = true
# #     File.open(path_to_file) { |f| uploader.store!(f) }
# #   end

# #   after do
# #     AvatarMyUploader.enable_processing = false
# #     uploader.remove!
# #   end

# #   context 'the thumb version' do
# #     it "scales down an image to be exactly 50 by 50 pixels" do
# #       expect(uploader.thumb).to have_dimensions(50, 50)
# #     end
# #   end

# #   context 'the large version' do
# #     it "scales down a landscape image to fit within 250 by 250 pixels" do
# #       expect(uploader.large).to be_no_larger_than(250, 250)
# #     end
# #   end

# #   it "makes the image readable only to the owner and not executable" do
# #     expect(uploader).to have_permissions(0600)
# #   end

# #   it "has the correct format" do
# #     expect(uploader).to be_format('png')
# #   end
# # end