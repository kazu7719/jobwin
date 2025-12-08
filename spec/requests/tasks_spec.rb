require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:task) do
    create(
      :task,
      user: user,
      task_name: "テストタスク",
      start_day: Date.new(2024, 2, 1),
      schedule_end_day: Date.new(2024, 2, 5),
      end_day: Date.new(2024, 2, 10),
      memo: "タスクのメモ"
    )
  end

  before { sign_in user }

  describe "GET /tasks" do
    before { get tasks_path }

    it "indexアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "indexアクションにリクエストするとレスポンスに登録済みのタスク名が存在する" do
      expect(response.body).to include(task.task_name)
    end

    it "indexアクションにリクエストするとレスポンスに登録済みの開始日がタスク存在する" do
      expect(response.body).to include(task.start_day.strftime('%Y/%m/%d'))
    end

    it "indexアクションにリクエストするとレスポンスに登録済みのタスク予定終了日が存在する" do
      expect(response.body).to include(task.schedule_end_day.strftime('%Y/%m/%d'))
    end
  end

  describe "GET /tasks/:id" do
    before { get task_path(task) }

    it "showアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "showアクションにリクエストするとレスポンスに登録済みのタスク名が存在する" do
      expect(response.body).to include(task.task_name)
    end

    it "showアクションにリクエストするとレスポンスに登録済みのタスク開始日が存在する" do
      expect(response.body).to include(task.start_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのタスク予定終了日が存在する" do
      expect(response.body).to include(task.schedule_end_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのタスク終了日が存在する" do
      expect(response.body).to include(task.end_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのタスクのメモが存在する" do
      expect(response.body).to include(task.memo)
    end
  end
end