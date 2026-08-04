require 'rails_helper'

RSpec.describe "Venues", type: :request do
  describe "venues" do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user) }
    let(:event) { create(:event, group: group, user: user) }
    before do
      sign_in user
    end

    it "予約情報を作成できること" do
      expect { post group_event_venues_path(group, event), params: {
        venue: { name: "居酒屋" }
        }, as: :turbo_stream
      }.to change(Venue, :count).by(1)
      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('action="append"')
      expect(response.body).to include('target="venues-list"')
    end

    it "予約情報を更新できること" do
      venue = create(:venue, event: event)
      patch group_event_venue_path(group, event, venue), params: {
        venue: { name: "修正後" }
      }, as: :turbo_stream
      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream] 
      expect(response.body).to include('action="replace"')
      expect(response.body).to include(`target="venue_#{venue.id}"`)
      expect(venue.reload.name).to eq "修正後"
    end

    it "予約情報を削除できること" do
      venue = create(:venue, event: event)
      expect { delete group_event_venue_path(group, event, venue)
      }.to change(Venue, :count).by(-1)
      expect(Venue.count).to eq 0
    end
  end
end
