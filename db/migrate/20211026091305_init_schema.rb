class InitSchema < ActiveRecord::Migration[5.2]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"

    create_enum :jurisdiction, %w(
      'unknown'
      'local'
      'state'
      'federal'
      'university'
      'commercial'
    )

    create_table "agencies" do |t|
      t.string "character", null: false
      t.string "street_address"
      t.string "city"
      t.integer "state_id"
      t.string "zipcode"
      t.string "telephone"
      t.string "email"
      t.string "website"
      t.string "slug"
      t.float "latitude"
      t.float "longitude"
      t.enum "jurisdiction", enum_name: :jurisdiction
      t.timestamps
    end

    create_table "ahoy_events", id: :uuid, default: nil do |t|
      t.uuid "visit_id"
      t.integer "user_id"
      t.string "name"
      t.text "properties"
      t.datetime "time"
      t.index ["name"], name: "index_ahoy_events_on_name"
      t.index ["time"], name: "index_ahoy_events_on_time"
      t.index ["user_id"], name: "index_ahoy_events_on_user_id"
      t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
    end
    create_table "calendar_events" do |t|
      t.string "title", null: false
      t.string "street_address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.string "format"
      t.text "description", null: false
      t.jsonb "schedule", null: false
      t.bigint "owner_id"
      t.index ["owner_id"], name: "index_calendar_events_on_owner_id"
    end
    create_table "case_agencies" do |t|
      t.integer "case_id"
      t.integer "agency_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "case_officers" do |t|
      t.integer "case_id"
      t.integer "officer_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    # Could not dump table "cases" because of following StandardError
    #   Unknown type 'cause_of_death' for column 'cause_of_death_name'

    create_enum :cause_of_death, %w(
      'choking'
      'shooting'
      'beating'
      'taser'
      'vehicular'
      'medical neglect'
      'response to medical emergency'
      'suicide'
      'chemical_agents_or_weapons'
      'drowning'
      'stabbing'
      'bombing'
    )

    create_table "cases" do |t|
      t.string "title", null: false
      t.enum :cause_of_death, enum_name: :cause_of_death
      t.datetime "date"
      t.integer "state_id"
      t.string "city"
      t.string "address"
      t.string "zipcode"
      t.float "latitude"
      t.float "longitude"
      t.string "avatar"
      t.string "slug"
      t.string "video_url"
      t.string "state"
      t.integer "age"
      t.string "overview", null: false
      t.text "community_action"
      t.text "litigation"
      t.string "country"
      t.boolean "remove_avatar"
      t.text  "summary", null: false
      t.integer "follows_count", null: false, default: 0
      t.string "default_avatar_url"
      t.text "blurb"
      t.timestamps
    end


    create_table "comments" do |t|
      t.text "content"
      t.integer "commentable_id"
      t.string "commentable_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "user_id"
      t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    end
    create_table "ethnicities" do |t|
      t.string "title"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "slug"
    end

    create_table "follows" do |t|
      t.integer "followable_id", null: false
      t.string "followable_type", null: false
      t.integer "follower_id", null: false
      t.string "follower_type", null: false
      t.boolean "blocked", default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["created_at"], name: "index_follows_on_created_at"
      t.index ["followable_id", "followable_type"], name: "fk_followables"
      t.index ["follower_id", "follower_type"], name: "fk_follows"
    end
    create_table "friendly_id_slugs" do |t|
      t.string "slug", null: false
      t.integer "sluggable_id", null: false
      t.string "sluggable_type", limit: 50
      t.string "scope"
      t.datetime "created_at"
      t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    end
    create_table "genders" do |t|
      t.string "sex"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "slug"
    end
    create_table "links" do |t|
      t.string "url"
      t.integer "linkable_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "title"
      t.string "linkable_type"
      t.index ["linkable_id", "linkable_type"], name: "index_links_on_linkable_id_and_linkable_type"
      t.index ["linkable_id"], name: "index_links_on_linkable_id"
    end
    create_table "mailboxer_conversation_opt_outs" do |t|
      t.integer "unsubscriber_id"
      t.string "unsubscriber_type"
      t.integer "conversation_id"
      t.index ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id"
      t.index ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type"
    end
    create_table "mailboxer_conversations" do |t|
      t.string "subject", default: ""
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "mailboxer_notifications" do |t|
      t.string "type"
      t.text "body"
      t.string "subject", default: ""
      t.integer "sender_id"
      t.string "sender_type"
      t.integer "conversation_id"
      t.boolean "draft", default: false
      t.string "notification_code"
      t.integer "notified_object_id"
      t.string "notified_object_type"
      t.string "attachment"
      t.datetime "updated_at", null: false
      t.datetime "created_at", null: false
      t.boolean "global", default: false
      t.datetime "expires"
      t.index ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id"
      t.index ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type"
      t.index ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type"
      t.index ["type"], name: "index_mailboxer_notifications_on_type"
    end
    create_table "mailboxer_receipts" do |t|
      t.integer "receiver_id"
      t.string "receiver_type"
      t.integer "notification_id", null: false
      t.boolean "is_read", default: false
      t.boolean "trashed", default: false
      t.boolean "deleted", default: false
      t.string "mailbox_type", limit: 25
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["notification_id"], name: "index_mailboxer_receipts_on_notification_id"
      t.index ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type"
    end
    create_table "organizations" do |t|
      t.string "name"
      t.text "description"
      t.string "website"
      t.string "telephone"
      t.string "avatar"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "rollout_histories" do |t|
      t.string "rollout_name", null: false
      t.date "change_date", null: false
      t.text "change_description", null: false
      t.string "author_name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "sessions" do |t|
      t.string "session_id", null: false
      t.text "data"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
      t.index ["updated_at"], name: "index_sessions_on_updated_at"
    end
    create_table "states" do |t|
      t.string "name"
      t.string "iso"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "ansi_code"
      t.string "slug"
      t.index ["ansi_code"], name: "index_states_on_ansi_code"
      t.index ["name"], name: "index_states_on_name"
    end
    create_table "subjects" do |t|
      t.string "name", null: false
      t.integer "age"
      t.integer "gender_id"
      t.integer "ethnicity_id"
      t.boolean "unarmed"
      t.boolean "mentally_ill"
      t.boolean "veteran"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "case_id"
      t.boolean "homeless"
    end
    create_table "users" do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "admin", default: false
      t.float "latitude"
      t.float "longitude"
      t.string "name", null: false
      t.text "description"
      t.integer "state_id"
      t.string "state"
      t.string "city"
      t.string "facebook_url"
      t.string "twitter_url"
      t.string "linkedin"
      t.string "slug"
      t.boolean "subscribed"
      t.boolean "analyst", default: false
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.index ["admin"], name: "index_users_on_admin"
      t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
      t.index ["created_at"], name: "index_users_on_created_at"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["slug"], name: "index_users_on_slug", unique: true
    end
    create_table "version_associations" do |t|
      t.integer "version_id"
      t.string "foreign_key_name", null: false
      t.integer "foreign_key_id"
      t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key"
      t.index ["version_id"], name: "index_version_associations_on_version_id"
    end
    create_table "versions" do |t|
      t.string "item_type", null: false
      t.integer "item_id", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.text "object"
      t.datetime "created_at"
      t.text "object_changes"
      t.string "ip"
      t.integer "transaction_id"
      t.text "comment", default: ""
      t.integer "author_id"
      t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
      t.index ["transaction_id"], name: "index_versions_on_transaction_id"
    end
    create_table "visits", id: :uuid, default: nil do |t|
      t.uuid "visitor_id"
      t.string "ip"
      t.text "user_agent"
      t.text "referrer"
      t.text "landing_page"
      t.integer "user_id"
      t.string "referring_domain"
      t.string "search_keyword"
      t.string "browser"
      t.string "os"
      t.string "device_type"
      t.integer "screen_height"
      t.integer "screen_width"
      t.string "country"
      t.string "region"
      t.string "city"
      t.string "utm_source"
      t.string "utm_medium"
      t.string "utm_term"
      t.string "utm_content"
      t.string "utm_campaign"
      t.datetime "started_at"
      t.index ["started_at"], name: "index_visits_on_started_at"
      t.index ["user_id"], name: "index_visits_on_user_id"
    end
    add_foreign_key "links", "cases", column: "linkable_id"
    add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
    add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
    add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
    add_foreign_key "subjects", "cases", on_delete: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
