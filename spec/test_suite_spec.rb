# frozen_string_literal: true

require "rails_helper"
require "active_support/core_ext/string/inflections"

RSpec.describe "TestSuite" do
  Dir["{app}/**/*.rb"].each do |filename|
    context filename do
      subject { filename }

      let(:testfile) do
        filename
          .sub("app", "spec")
          .sub(".rb", "_spec.rb")
      end

      it "has tests" do
        next if testfile =~ /(controllers|inputs|models|search|jobs|uploaders)\/.+_spec.rb/ # Very few models require testing, so not to create "it exists"... Feel free to deduct/add other folders

        expect(File.exist?(testfile)).to be_truthy, "File `#{testfile}` must exist.  Please create it and include tests for your newly added methods."
        class_name = File.basename(filename, ".rb").camelcase
        File.open(testfile, :encoding => "utf-8") do |file|
          expect(file.read.downcase).to match(class_name.downcase)
        end
      end
    end
  end
end
