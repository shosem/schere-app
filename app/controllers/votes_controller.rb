class VotesController < ApplicationController
  before_action :signed_in!
  before_action :set_group
  before_action :set_event

  def create
    # 投票者セット
    voter = current_user || current_guest

    # paramsで受け取る、{候補日id=>回答}たちを分解
    params[:votes].each do |candidate_date_id, answer|

      # 候補日がちゃんとeventに属しているかを確認しつつセット
      candidate_date = @event.candidate_dates.find_by(id: candidate_date_id)

      # 候補日がイベントにないなら次のループに（スキップ）
      next unless candidate_date

      # voteに、存在するならvoter: voterをセット。なければビルド
      vote = candidate_date.votes.find_or_initialize_by(voter: voter)

      # voteのアンサーに、paramsのアンサーをセット
      vote.answer = answer
      vote.save
    end

    redirect_to group_event_path(@group, @event), notice: "投票しました"
  end


  private

  def set_group
    @group = Group.find(params[:group_id])
    deny_access unless authorized?(@group)
  end

  def set_event
    @event = @group.events.find(params[:event_id])
  end
end
