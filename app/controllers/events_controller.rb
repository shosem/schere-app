class EventsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :signed_in!, only: :show
  before_action :set_group

  def new
    @event = @group.events.build
    @event.candidate_dates.build
  end

  def create
    @event = @group.events.build(event_paramas)
    @event.user = current_user
    if @event.save
      redirect_to group_path(@group), notice: "イベントを作成しました"
    else
      flash.now[:alert] = "イベントを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # イベントをセット
    @event = @group.events.find(params[:id])

    # イベントの候補日たちを、投票データとともにセット
    @candidate_dates = @event.candidate_dates.includes(:votes).order(:date, :start_time)

    # 投票者をセット
    voter = current_user || current_guest

    # 投票の数をセットする入れ物。候補日=>{回答=>数}となる
    @vote_counts = {}

    # 投票者の名前をセットする入れ物。候補日=>{回答=>[名前たち]}
    @voter_names = {}

    # 自分の投票の入れ物。{候補日=>回答}となる
    @my_votes = {}

    # 丸の投票が一番多い候補日のidの配列
    @top_available_day_ids = @event.top_available_candidate_date_ids

    # ×の投票が一番少ない候補日のidの配列
    @fewest_unavailable_day_ids = @event.fewest_unavailable_candidate_date_ids

    # 候補日たちを分解し、候補日ごとの回答を見ていく
    # また、候補日ごとの入れ物を作っておく。初期値を入れておかないと、nilになってしまう
    @candidate_dates.each do |cd|
      @vote_counts[cd.id] = { "available" => 0, "maybe" => 0, "unavailable" => 0 }
      @voter_names[cd.id]  = { "available" => [], "maybe" => [], "unavailable" => [] }
      cd.votes.each do |vote|
        # 候補日=>{回答=>数}に1を足す
        @vote_counts[cd.id][vote.answer] += 1

        # 候補日=>{回答=>[名前たち]} に名前を追加していく
        @voter_names[cd.id][vote.answer] << vote.voter.name

        # voterが存在するとき、投票者のタイプがvoterと一致して、投票者のidがvoterと一致する、つまり投票者 = 見てる人なら
        if voter && vote.voter_type == voter.class.name && vote.voter_id == voter.id

          # 自分の投票一覧に足す
          @my_votes[cd.id] = vote.answer
        end
      end
    end
  end

  private

  def event_paramas
    params.require(:event).permit(:title, :description, :location, candidate_dates_attributes: [ :id, :date, :start_time, :end_time ])
  end

  def set_group
    @group = Group.find(params[:group_id])
    deny_access unless authorized?(@group)
  end
end
