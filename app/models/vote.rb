class Vote < ApplicationRecord
  belongs_to :candidate_date
  belongs_to :voter, polymorphic: true
  validates :answer, presence: true
  validates :voter_id, uniqueness: { scope: [ :candidate_date_id, :voter_type ] }
  enum :answer, { unavailable: 0, maybe: 1, available: 2 }

  def self.answered_counts_by_event(events)
    joins(:candidate_date).where(candidate_dates: { event_id: events }).group("candidate_dates.event_id").count("DISTINCT (voter_type, voter_id)").tap { |h| h.default = 0 }
  end

  # 候補日->回答数を表示するメソッド（返り値はハッシュなので、メソッド[候補日]でとれる）
  def self.answer_counts(events, answer)
    cds = events.map { |event| event.confirmed_candidate_date_id }.compact
    where(candidate_date_id: cds, answer: answer).group(:candidate_date_id).count.tap { |h| h.default = 0 }
  end
end
