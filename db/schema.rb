# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130210205031) do

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "features", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "category_id"
  end

  add_index "features", ["category_id"], :name => "index_features_on_category_id"
  add_index "features", ["name"], :name => "index_features_on_name", :unique => true

  create_table "filters", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.string   "area"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "filters", ["area"], :name => "index_filters_on_scope"
  add_index "filters", ["name"], :name => "index_filters_on_name"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "team_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "projects", ["name"], :name => "index_projects_on_name"

  create_table "reference_types", :force => true do |t|
    t.string   "name"
    t.string   "url_pattern"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "reference_types", ["name"], :name => "index_reference_types_on_name", :unique => true

  create_table "references", :force => true do |t|
    t.integer  "reference_type_id"
    t.string   "value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "references", ["reference_type_id"], :name => "index_references_on_reference_type_id"

  create_table "referent_references", :force => true do |t|
    t.integer  "referent_id"
    t.string   "referent_type"
    t.integer  "reference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "referent_references", ["reference_id"], :name => "index_referent_references_on_reference_id"
  add_index "referent_references", ["referent_id", "referent_type", "reference_id"], :name => "referent_unique_reference", :unique => true
  add_index "referent_references", ["referent_id", "referent_type"], :name => "index_referent_references_on_referent_id_and_referent_type"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "stories", :force => true do |t|
    t.datetime "release_date"
    t.string   "title"
    t.integer  "feature_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "stories", ["feature_id"], :name => "index_features_on_service_id"
  add_index "stories", ["release_date"], :name => "index_features_on_release_date"

  create_table "supported_features", :force => true do |t|
    t.integer  "project_id"
    t.integer  "feature_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
  end

  add_index "supported_features", ["feature_id", "project_id"], :name => "index_supported_features_on_feature_id_and_project_id", :unique => true
  add_index "supported_features", ["feature_id"], :name => "index_supported_features_on_feature_id"
  add_index "supported_features", ["project_id"], :name => "index_supported_features_on_project_id"
  add_index "supported_features", ["status"], :name => "index_supported_features_on_status"

  create_table "tasks", :force => true do |t|
    t.integer  "story_id"
    t.integer  "project_id"
    t.string   "status"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "title"
    t.float    "rank"
    t.integer  "points",         :default => 0
    t.text     "description"
    t.datetime "start_date"
    t.datetime "completed_date"
  end

  add_index "tasks", ["project_id"], :name => "index_stories_on_project_id"
  add_index "tasks", ["rank"], :name => "index_tasks_on_rank"
  add_index "tasks", ["status"], :name => "index_stories_on_status"
  add_index "tasks", ["story_id"], :name => "index_stories_on_feature_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "velocity"
    t.integer  "iteration",  :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "teams", ["name"], :name => "index_teams_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
