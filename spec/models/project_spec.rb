require 'rails_helper'

RSpec.describe Project, type: :model do
  before do
    @project = FactoryBot.build(:project)
    @project.project_tasks << FactoryBot.build(:project_task, project: @project, user: @project.user)
  end

  describe '新規登録できる場合' do
    it 'project_name、start_day、schedule_end_day、end_day、memo、project_taskモデルのproject_task_nameが存在すれば保存できる' do
      expect(@project).to be_valid
    end

    it 'end_dayが空でも保存できる' do
      @project.end_day = nil
      expect(@project).to be_valid
    end

    it 'memoが空でも保存できる' do
      @project.memo = ''
      expect(@project).to be_valid
    end
  end

  describe '新規登録できない場合' do
    it 'project_nameが空では登録できない' do
      @project.project_name = ''
      expect(@project).to be_invalid
    end

    it 'start_dayが空では登録できない' do
      @project.start_day = nil
      expect(@project).to be_invalid
    end

    it 'schedule_end_dayが空では登録できない' do
      @project.schedule_end_day = nil
      expect(@project).to be_invalid
    end

    it 'project_taskモデルのproject_task_nameが空では登録できない' do
      @project.project_tasks.first.project_task_name = ''
      expect(@project).to be_invalid
    end

    it 'userが紐づいてないと登録できない' do
      @project.user = nil
      expect(@project).to be_invalid
    end
  end
end