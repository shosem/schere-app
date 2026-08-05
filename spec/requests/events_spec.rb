require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "events" do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user) }
    let(:event) { create(:event, group: group, user: user, candidate_dates_count: 3) }
    before do
      event.update!(confirmed_candidate_date_id: event.candidate_dates.first.id, status: "confirmed")
      sign_in user
    end
    context "確定済みイベントに、確定日程を削除するリクエストを送る場合" do
      it "削除されないこと" do
        patch group_event_path(event.group, event), params: {
          event: { candidate_dates_attributes: [ id: event.confirmed_candidate_date_id, _destroy: 1 ] } }
        expect(response).to redirect_to group_event_path(group, event)
        expect(event.reload.confirmed_candidate_date_id).to eq event.candidate_dates.first.id
        expect(event.candidate_dates.count).to eq 3
        expect(event.status).to be_confirmed
      end
    end
  end
end
