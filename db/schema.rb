# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_12_27_120000) do
  create_table "habits", charset: "utf8mb3", force: :cascade do |t|
    t.string "habit_name"
    t.datetime "start_day"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "project_tasks", charset: "utf8mb3", force: :cascade do |t|
    t.string "project_task_name"
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false, null: false
    t.integer "position", default: 0, null: false
    t.index ["project_id", "position"], name: "index_project_tasks_on_project_id_and_position"
    t.index ["project_id"], name: "index_project_tasks_on_project_id"
    t.index ["user_id"], name: "index_project_tasks_on_user_id"
  end

  create_table "projects", charset: "utf8mb3", force: :cascade do |t|
    t.string "project_name"
    t.datetime "start_day"
    t.datetime "schedule_end_day"
    t.datetime "end_day"
    t.text "memo"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "tasks", charset: "utf8mb3", force: :cascade do |t|
    t.string "task_name"
    t.datetime "start_day"
    t.datetime "schedule_end_day"
    t.datetime "end_day"
    t.text "memo"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "nickname", null: false
    t.integer "labor_id", null: false
    t.string "goal", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "habits", "users"
  add_foreign_key "project_tasks", "projects"
  add_foreign_key "project_tasks", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "tasks", "users"
end
