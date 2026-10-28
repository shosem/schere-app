require 'rails_helper'

RSpec.describe Vote, type: :model do
  context "作成可能" do
    let(:user) { create(:user) }
    let(:candidate_date) { create(:candidate_date) }

    it "ユーザーが投票できること" do
      vote = build(:user_vote)
      expect(vote).to be_valid
    end

    it "ゲストが投票できること" do
      vote = build(:guest_vote)
      expect(vote).to be_valid
    end

    it "同じ候補日でも、user/guestのタイプが違えば投票できること" do
      create(:user_vote, voter: user, candidate_date: candidate_date)
      vote = build(:guest_vote, candidate_date: candidate_date)
      expect(vote).to be_valid
    end
  end

  context "作成不可" do
    let(:user) { create(:user) }
    let(:candidate_date) { create(:candidate_date) }
    it "同じ候補日に同じ投票者が複数投票できないこと" do
      create(:user_vote, voter: user, candidate_date: candidate_date)
      expect(Vote.count).to eq 1
      vote = build(:user_vote, voter: user, candidate_date: candidate_date)
      expect(vote).to be_invalid
      expect(vote.errors[:voter_id]).to be_present
    end
  end

  context ".answered_counts_by_event" do
    let(:group) { create(:group) }
    let(:event) { create(:event, group: group, candidate_dates_count: 2) }

    it "イベントごとに、回答した人数を返すこと" do
      create(:vote, candidate_date: event.candidate_dates.first, voter: create(:user))
      create(:vote, candidate_date: event.candidate_dates.first, voter: create(:guest, group: group))

      expect(Vote.answered_counts_by_event([ event ])).to eq({ event.id => 2 })
    end

    it "同じ人が複数の候補日に投票していても、1人として数えること" do
      user = create(:user)
      event.candidate_dates.each { |cd| create(:vote, candidate_date: cd, voter: user) }

      expect(Vote.count).to eq 2
      expect(Vote.answered_counts_by_event([ event ])[event.id]).to eq 1
    end

    it "idが同じでも、UserとGuestは別人として数えること" do
      user = create(:user)
      guest = create(:guest, id: user.id, group: group)
      create(:vote, candidate_date: event.candidate_dates.first, voter: user)
      create(:vote, candidate_date: event.candidate_dates.first, voter: guest)

      expect(Vote.answered_counts_by_event([ event ])[event.id]).to eq 2
    end

    it "回答が1件も無いイベントは、0を返すこと" do
      expect(Vote.answered_counts_by_event([ event ])[event.id]).to eq 0
    end

    it "他のイベントの投票を数えないこと" do
      other_event = create(:event, group: group)
      create(:vote, candidate_date: other_event.candidate_dates.first, voter: create(:user))

      expect(Vote.answered_counts_by_event([ event ])[event.id]).to eq 0
    end
  end

  context ".answer_counts" do
    let(:group) { create(:group) }
    let(:event) { create(:event, group: group, candidate_dates_count: 2) }
    let(:confirmed_date) { event.candidate_dates.first }
    let(:other_date) { event.candidate_dates.second }

    before { event.update!(confirmed_candidate_date: confirmed_date, status: :confirmed) }

    it "確定日に、指定した回答をした人数を返すこと" do
      create(:vote, candidate_date: confirmed_date, voter: create(:user))
      create(:vote, candidate_date: confirmed_date, voter: create(:guest, group: group))

      expect(Vote.answer_counts([ event ], "available")).to eq({ confirmed_date.id => 2 })
    end

    it "指定した回答以外は数えないこと" do
      create(:vote, :maybe, candidate_date: confirmed_date, voter: create(:user))

      expect(Vote.answer_counts([ event ], "available")[confirmed_date.id]).to eq 0
    end

    it "確定日以外の候補日への投票は数えないこと" do
      create(:vote, candidate_date: other_date, voter: create(:user))

      expect(Vote.answer_counts([ event ], "available")[confirmed_date.id]).to eq 0
    end

    it "確定していないイベントは、対象にならないこと" do
      adjusting_event = create(:event, group: group)
      create(:vote, candidate_date: adjusting_event.candidate_dates.first, voter: create(:user))

      expect(Vote.answer_counts([ adjusting_event ], "available")).to be_empty
    end
  end
end
