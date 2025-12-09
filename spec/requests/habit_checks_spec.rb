require 'rails_helper'

RSpec.describe "習慣チェック", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:habit) { create(:habit, user: user, start_day: Date.current - 2.days) }
  let(:headers) { { "ACCEPT" => "application/json" } }

  describe "PATCH /habits/:habit_id/habit_checks" do
    context "サインイン済みの場合" do
      before { sign_in user }

      it "習慣チェックを作成または更新して進捗を返す" do
        expect {
          patch habit_habit_checks_path(habit), params: { check_date: Date.current, completed: true }, headers: headers
        }.to change { habit.habit_checks.count }.by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["progress_text"]).to include("1 /")
      end

      it "不正な日付の場合はエラーを返す" do
        patch habit_habit_checks_path(habit), params: { check_date: "invalid-date", completed: true }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end

    context "別ユーザーの習慣にアクセスする場合" do
      let(:other_user) { create(:user) }
      let(:other_habit) { create(:habit, user: other_user, start_day: Date.current - 1.day) }

      before { sign_in user }

      it "404を返す" do
        patch habit_habit_checks_path(other_habit), params: { check_date: Date.current, completed: true }, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "未サインインの場合" do
      it "サインインを求めるレスポンスを返す" do
        patch habit_habit_checks_path(habit), params: { check_date: Date.current, completed: true }, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end