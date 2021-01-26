# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210107135703) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "monthly_status"
    t.string "monthly_superior_confirmation"
    t.datetime "edit_started_at"
    t.datetime "edit_finished_at"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.boolean "next_day"
    t.string "edit_status"
    t.string "edit_superior_confirmation"
    t.date "approval_date"
    t.datetime "scheduled_end_time"
    t.boolean "overwork_next_day"
    t.string "work_details"
    t.string "overwork_request_status"
    t.string "overwork_superior_confirmation"
    t.boolean "change"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "hub_number"
    t.string "name"
    t.string "attendance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2021-01-26 23:00:00"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time"
    t.datetime "designated_work_end_time"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
