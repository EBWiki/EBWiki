require 'rails_helper'

  describe Event do
    it "is invalid without a title" do
      event = build(:event, title: nil)
      expect(event).to be_invalid
    end
    it "is invalid without a date" do
      event = build(:event, date: nil)
      expect(event).to be_invalid
    end
    it "is invalid without an article_id" do
      event = build(:event, article_id: nil)
      expect(event).to be_invalid
    end
    it "must have a unique name" do
      event = build(:event, title: 'john smith', article_id: 1)
      event.save
      event2 = build(:event, title: 'john smith', article_id: 1)
      expect(event2).to be_invalid
    end

    it "may have the same name of an event of a separate article" do
      event = build(:event, title: 'john smith', article_id: 1)
      event.save
      event2 = build(:event, title: 'john smith', article_id: 2)
      expect(event2).to be_valid
    end
   #  it "returns a sorted array of results that match" do
   #   smith = Event.create(
   #     title: 'John Smith',
   #     content: 'A new victim'
   #   )
   #   jones = Event.create(
   #     title: 'John Jones',
   #     content: 'A new victim'
   #   )
   #   james = Event.create(
   #     title: 'Jane James',
   #     content: 'A new victim'
   #   )
   #   smith.reindex
   #   jones.reindex
   #   james.reindex
   #   Event.searchkick_index.refresh
   #   expect(Event.find_by_search("John")).to eq [smith, jones]
   # end
  end

  describe "#new" do
    it "takes three parameters and returns an Event object" do
		event = build(:event)
        event.should be_an_instance_of Event
    end
  end

  describe "#title" do
    it "returns the correct title" do
	  	event = build(:event)
        expect(event.title).to include "A new event happened"
    end
  end

  describe "#description" do
    it "returns the correct content" do
	  	event = build(:event)
        expect(event.description).to eq "MyText"
    end
  end