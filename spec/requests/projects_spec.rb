require 'rails_helper'

RSpec.describe "Projects", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let!(:project) do
    create(
      :project,
      user: user,
      project_name: "テストプロジェクト",
      start_day: Date.new(2024, 1, 1),
      schedule_end_day: Date.new(2024, 1, 10),
      end_day: Date.new(2024, 1, 20),
      memo: "プロジェクトのメモ"
    )
  end
  let!(:project_task) do
    create(:project_task, project: project, user: user, project_task_name: "タスク1")
  end

  before { sign_in user }

  describe "GET /projects" do
    before { get projects_path }

    it "indexアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "indexアクションにリクエストするとレスポンスに登録済みのプロジェクト名が存在する" do
      expect(response.body).to include(project.project_name)
    end

    it "indexアクションにリクエストするとレスポンスに登録済みのプロジェクト開始日が存在する" do
      expect(response.body).to include(project.start_day.strftime('%Y/%m/%d'))
    end

    it "indexアクションにリクエストするとレスポンスに登録済みのプロジェクト予定終了日が存在する" do
      expect(response.body).to include(project.schedule_end_day.strftime('%Y/%m/%d'))
    end
  end

  describe "GET /projects/:id" do
    before { get project_path(project) }

    it "showアクションにリクエストすると正常にレスポンスが返ってくる" do
      expect(response).to have_http_status(:ok)
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクト名が存在する" do
      expect(response.body).to include(project.project_name)
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクト開始日が存在する" do
      expect(response.body).to include(project.start_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクト予定終了日が存在する" do
      expect(response.body).to include(project.schedule_end_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクト終了日が存在する" do
      expect(response.body).to include(project.end_day.strftime('%Y/%m/%d'))
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクトのメモが存在する" do
      expect(response.body).to include(project.memo)
    end

    it "showアクションにリクエストするとレスポンスに登録済みのプロジェクトタスクモデルのタスク一覧が存在する" do
      expect(response.body).to include(project_task.project_task_name)
    end
  end
end