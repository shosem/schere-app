require 'rails_helper'

# エラーページは「壊れていても本番では気付けない」種類のコード。
# 描画中に例外が起きると画面には真っ黒なテキストしか出ず、ユーザーは報告してこない。
# 壊れたことを知る手段がこのテストしかないので、経路ごとに固定する。
RSpec.describe "Errors", type: :request do
  # test環境の既定ではエラーページまで到達しないため、つまみを2つ差し替える。
  #   show_exceptions          : :rescuable → :all
  #     rescue_responses に載っていない例外（= 500になるもの）がテストに投げ返される
  #   show_detailed_exceptions : true → false
  #     DebugExceptions が ShowExceptions より先にデバッグ画面を返してしまう
  #     （config/environments/test.rb の consider_all_requests_local = true 由来）
  OVERRIDES = {
    "action_dispatch.show_exceptions" => :all,
    "action_dispatch.show_detailed_exceptions" => false
  }.freeze

  around do |example|
    env = Rails.application.env_config
    originals = env.slice(*OVERRIDES.keys)
    env.merge!(OVERRIDES)
    begin
      example.run
    ensure
      env.merge!(originals)
    end
  end

  describe "存在しないパスにアクセスした場合" do
    it "404ページが404ステータスで表示されること" do
      get "/no_such_page"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("お探しのページは存在しません")
    end
  end

  describe "存在しないIDのグループにアクセスした場合" do
    let(:user) { create(:user) }

    before { sign_in user }

    # 上と例外の種類が違う（RoutingError ではなく RecordNotFound）。
    # ミドルウェアまで浮かび上がる経路が別なので、両方を固定する。
    it "404ページが404ステータスで表示されること" do
      get "/groups/999999"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("お探しのページは存在しません")
    end
  end

  describe "サーバ内部で例外が起きた場合" do
    before do
      allow_any_instance_of(PagesController).to receive(:terms).and_raise("意図的なエラー")
    end

    it "500ページが500ステータスで表示されること" do
      get "/terms"

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include("エラーが発生しました")
    end

    # 500は「アプリが壊れている」状況で出る。ヘッダーは current_user /
    # current_guest を参照する＝DBを引くため、DBが原因の500ではエラーページ
    # 自体が落ちる（double fault）。それを避けるためヘッダーを出さない。
    it "ヘッダーを描画しないこと" do
      get "/terms"

      expect(response.body).not_to include("新規登録")
      expect(response.body).not_to include("ログアウト")
    end

    # ShowExceptions は PATH_INFO を "/500" に書き換えるため、request.path は
    # 使えない。退避された action_dispatch.original_path を見る必要がある。
    it "再読み込みリンクが元のパスを指すこと" do
      get "/terms"

      expect(response.body).to include('href="/terms"')
      expect(response.body).not_to include('href="/500"')
    end
  end
end
