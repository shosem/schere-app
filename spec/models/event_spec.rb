require 'rails_helper'

RSpec.describe Event, type: :model do
  context "作成可能" do
    it "候補日を持ったイベントを正常に作成できること" do
      event = build(:event)
      expect(event).to be_valid
    end
  end

  context "作成不可" do
    it "タイトルが空白の場合作成できないこと" do
      event = build(:event, title: "")
      expect(event).to be_invalid
      expect(event.errors[:title]).to be_present
    end

    it "候補日を設定しない場合イベントを作成できないこと" do
      event = build(:event, candidate_dates_count: 0)
      expect(event).to be_invalid
      expect(event.errors[:candidate_dates]).to be_present
    end
  end

  describe "#top_available_candidate_date_ids" do
    let(:event) { create(:event, candidate_dates_count: 3) }

    context "○最多の候補日が1つのとき" do
      it "そのidを返すこと" do
        top_available_cd = event.candidate_dates.first

        create(:user_vote, candidate_date: top_available_cd)
        create(:guest_vote, candidate_date: top_available_cd)

        expect(event.top_available_candidate_date_ids).to eq [ top_available_cd.id ]
      end
    end

    context "○最多の候補日が複数のとき" do
      it "該当の候補日idをすべて返すこと" do
        top_available_cd_1 = event.candidate_dates.first
        top_available_cd_2 = event.candidate_dates.last

        create(:user_vote, candidate_date: top_available_cd_1)
        create(:guest_vote, candidate_date: top_available_cd_2)
        expect(event.top_available_candidate_date_ids).to contain_exactly(top_available_cd_1.id, top_available_cd_2.id)
      end
    end

    context "○の投票が0のとき" do
      it "空の配列を返すこと" do
        cd1 = event.candidate_dates.first
        cd2 = event.candidate_dates.last
        create(:user_vote, :maybe, candidate_date: cd1)
        create(:guest_vote, :unavailable, candidate_date: cd2)
        expect(event.top_available_candidate_date_ids).to eq []
      end
    end
  end

  describe "#fewest_unavailable_candidate_date_ids" do
    let(:event) { create(:event, candidate_dates_count: 3) }

    context "×最少の候補日が1つのとき" do
      it "そのidを返すこと" do
        cd1, cd2, fewest_cd3 = event.candidate_dates.order(:id)

        create(:user_vote, :unavailable, candidate_date: cd1)
        create(:guest_vote, :unavailable, candidate_date: cd2)

        expect(event.fewest_unavailable_candidate_date_ids).to eq [ fewest_cd3.id ]
      end
    end

    context "×最少の候補日が複数のとき" do
      it "該当の候補日idをすべて返すこと" do
        cd1, fewest_cd2, fewest_cd3 = event.candidate_dates.order(:id)

        create(:user_vote, :unavailable, candidate_date: cd1)
        expect(event.fewest_unavailable_candidate_date_ids).to contain_exactly(fewest_cd2.id, fewest_cd3.id)
      end
    end

    context "全候補日の×が同数のとき" do
      it "空の配列を返すこと" do
        cd1, cd2, cd3 = event.candidate_dates.order(:id)
        create(:user_vote, candidate_date: cd1)
        create(:guest_vote, :maybe, candidate_date: cd2)
        expect(event.fewest_unavailable_candidate_date_ids).to eq []
      end
    end
  end
end
