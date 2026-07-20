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
end
