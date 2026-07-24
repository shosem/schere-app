class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :candidate_dates, dependent: :destroy
  has_many :venues, dependent: :destroy
  belongs_to :confirmed_candidate_date,
             class_name: "CandidateDate",
             optional: true
  accepts_nested_attributes_for :candidate_dates, allow_destroy: true
  enum :status, { adjusting: 0, confirmed: 1, cancelled: 2 }, default: :adjusting

  validates :title, presence: true, length: { maximum: 25 }
  validates :description, length: { maximum: 10_000 }
  validates :candidate_dates, presence: true

  def top_available_candidate_date_ids
    # ハッシュ{ 候補日ID => ○の数 }を取得する
    available_counts = {}
    self.candidate_dates.each do |c|
      available_counts[c.id] = c.votes.count { |v| v.answer == "available" }
    end

    # ハッシュの値（○の数）の配列の、最大数を取得
    max_available = available_counts.values.max

    return [] if max_available == nil || max_available == 0

    # 最大数と、○の数が一致する候補日idたちを取得
    # selectは条件一致のものを返す
    available_counts.select { |_id, n| n == max_available }.keys
  end

  def fewest_unavailable_candidate_date_ids
    unavailable_counts = {}
    self.candidate_dates.each do |c|
      unavailable_counts[c.id] = c.votes.count { |v| v.answer == "unavailable" }
    end

    counts  = unavailable_counts.values

    return [] if counts.max == counts.min

    min_unavailable = counts.min

    unavailable_counts.select { |_id, n| n == min_unavailable }.keys

  end
end
