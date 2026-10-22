# frozen_string_literal: true

namespace :case_photo_embedding do
  desc 'Embed every shown case photo with SigLIP on CPU (staging)'
  task run: :environment do
    summary = CasePhotoEmbedding::Runner.new.call
    puts summary.to_json
  end
end
