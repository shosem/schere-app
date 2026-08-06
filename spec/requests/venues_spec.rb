require 'rails_helper'

RSpec.describe "Venues", type: :request do
  describe "venues" do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user) }
    let(:event) { create(:event, group: group, user: user, candidate_dates_count: 3) }
    before do
      sign_in user
    end

    context "確定済みイベントの場合" do
      before do
        cd = event.candidate_dates.last
        event.update!(confirmed_candidate_date_id: cd.id, status: "confirmed")
      end

      it "施設情報を作成できること" do
        expect { post group_event_venues_path(group, event), params: {
          venue: { name: "居酒屋" }
          }, as: :turbo_stream
        }.to change(Venue, :count).by(1)
        expect(response).to have_http_status(200)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('action="append"')
        expect(response.body).to include('target="venues-list"')
      end

      it "施設情報を更新できること" do
        venue = create(:venue, event: event)
        patch group_event_venue_path(group, event, venue), params: {
          venue: { name: "修正後" }
        }, as: :turbo_stream
        expect(response).to have_http_status(200)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('action="replace"')
        expect(response.body).to include(%(target="venue_#{venue.id}"))
        expect(venue.reload.name).to eq "修正後"
      end

      it "施設情報を削除できること" do
        venue = create(:venue, event: event)
        expect { delete group_event_venue_path(group, event, venue)
        }.to change(Venue, :count).by(-1)
        expect(Venue.count).to eq 0
      end
    end

    context "調整中イベントの場合" do
      it "施設情報を作成できないこと" do
        post group_event_venues_path(group, event), params: {
          venue: { name: "居酒屋" }
          }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(group_event_path(group, event))
        expect(Venue.count).to eq 0
        expect(flash[:alert]).to eq "施設情報は確定済みのイベントのみ操作できます"
      end

      it "施設情報を更新できないこと" do
        venue = create(:venue, event: event)
        patch group_event_venue_path(group, event, venue), params: {
          venue: { name: "修正後" }
        }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(group_event_path(group, event))
      end

      it "施設情報を削除できないこと" do
        venue = create(:venue, event: event)
        expect { delete group_event_venue_path(group, event, venue)
        }.to_not change(Venue, :count)
        expect(Venue.count).to eq 1
      end

      it "施設情報の作成ページにアクセスしようとするとリダイレクトされること" do
        get new_group_event_venue_path(group, event)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(group_event_path(group, event))
      end
    end
  end
end
