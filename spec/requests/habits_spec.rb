require 'rails_helper'

RSpec.describe "Habits", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:habit) do
    create(
      :habit,
      user: user,
      habit_name: "テスト習慣",
      start_day: Date.new(2024, 1, 1)
    )
  end

  before { sign_in user }

  describe "GET /habits" do
    before { get habits_path }

    it "indexアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "indexアクションにリクエストするとレスポンスに登録済みの習慣名が存在する" do
      expect(response.body).to include(habit.habit_name)
    end

    it "indexアクションにリクエストするとカレンダーとチェックリストが表示される" do
      expect(response.body).to include("habit-table").and include("type=\"checkbox\"")
    end
  end

  describe "GET /habits/:id" do
    before { get habit_path(habit) }

    it "showアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "showアクションにリクエストするとレスポンスに登録済みの習慣名が存在する" do
      expect(response.body).to include(habit.habit_name)
    end

    it "showアクションにリクエストするとレスポンスに登録済みの習慣開始日が存在する" do
      expect(response.body).to include(habit.start_day.strftime('%Y/%m/%d'))
    end
  end
end