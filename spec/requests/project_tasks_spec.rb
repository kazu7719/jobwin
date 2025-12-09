require 'rails_helper'

RSpec.describe "プロジェクトタスク", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let!(:task1) { create(:project_task, project: project, user: user, position: 1) }
  let!(:task2) { create(:project_task, project: project, user: user, position: 2) }
  let!(:task3) { create(:project_task, project: project, user: user, position: 3) }

  before { sign_in user }

  describe "PATCH /projects/:project_id/project_tasks/:id の完了状態更新" do
    it "完了状態を更新する" do
      patch project_project_task_path(project, task1), params: { project_task: { completed: true } }

      expect(response).to have_http_status(:no_content)
      expect(task1.reload.completed).to be true
    end

    it "他ユーザーのプロジェクトには404を返す" do
      other_project = create(:project)
      other_task = create(:project_task, project: other_project, user: other_project.user)

      patch project_project_task_path(other_project, other_task), params: { project_task: { completed: true } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /projects/:project_id/project_tasks/sort の並び替え" do
    it "同一プロジェクト内のタスク順を更新する" do
      patch sort_project_project_tasks_path(project), params: { project_task_ids: [task3.id, task1.id, task2.id] }

      expect(response).to have_http_status(:no_content)
      expect(task3.reload.position).to eq(1)
      expect(task1.reload.position).to eq(2)
      expect(task2.reload.position).to eq(3)
    end

    it "不正なタスクIDを含む場合は422を返す" do
      original_positions = [task1.position, task2.position, task3.position]

      patch sort_project_project_tasks_path(project), params: { project_task_ids: [task1.id, 0, task2.id] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect([task1.reload.position, task2.reload.position, task3.reload.position]).to eq(original_positions)
    end
  end
end