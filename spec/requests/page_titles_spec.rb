require 'rails_helper'

# 守りたいのは default_meta_tags の計算結果ではなく、「レイアウトが
# display_meta_tags(default_meta_tags) を呼んでいること」。実装中、
# application.html.erb だけ直して auth.html.erb が取り残され、ログイン・
# 新規登録のタブが "ログイン"（サイト名なし）になった。
# default_meta_tags 自体は正しく動いていたので、ヘルパー単体のテストでは捕まらない。
#
# レイアウトは3枚（application / auth / error）あり、増える可能性もある。
# 1枚ずつ代表ページを通して、呼び忘れたレイアウトが混ざらないようにする。
RSpec.describe "ページタイトル", type: :request do
  describe "application レイアウト" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "ページ名とサイト名が並ぶこと" do
      get root_path

      expect(response.body).to include("<title>グループ一覧 | Schere</title>")
    end

    # 動的ページは中身の名前を入れる。「グループ詳細」で固定すると、タブを
    # 複数開いた人が見分けられなくなる。
    it "グループ詳細はグループ名が入ること" do
      group = create(:group, user: user, name: "テニスサークル")

      get group_path(group)

      expect(response.body).to include("<title>テニスサークル | Schere</title>")
    end
  end

  # devise_controller? のページはこちら（ApplicationController#set_layout）。
  describe "auth レイアウト" do
    it "ページ名とサイト名が並ぶこと" do
      get new_user_session_path

      expect(response.body).to include("<title>ログイン | Schere</title>")
    end
  end

  describe "error レイアウト" do
    # test環境の既定ではエラーページまで到達しない。つまみの意味は
    # spec/requests/errors_spec.rb のコメントを参照。
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

    it "ページ名とサイト名が並ぶこと" do
      get "/no_such_page"

      expect(response.body).to include("<title>エラー | Schere</title>")
    end
  end

  # content_for を書いていないページ（モーダルなど）でタイトルが空になると、
  # ブラウザはURLを表示する。フォールバックは meta-tags の site が持っている。
  describe "content_for を書いていないページ" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "サイト名だけが出ること" do
      get new_event_group_selection_path

      expect(response.body).to include("<title>Schere</title>")
    end
  end
end
