# frozen_string_literal: true

require "eb_wiki/rails_session"

module EbWiki
  module Repos
    class SessionRepo < EbWiki::DB::Repo
      def find_by_session_id(session_id)
        sessions.where(session_id: session_id).one
      end

      def upsert_for_user(session_id:, user_id:, encrypted_password:)
        data = EbWiki::RailsSession.payload_for(user_id, encrypted_password)
        now = Time.now.utc
        existing = find_by_session_id(session_id)
        if existing
          sessions.where(id: existing[:id]).update(data: data, updated_at: now)
        else
          sessions.insert(
            id: next_id,
            session_id: session_id,
            data: data,
            created_at: now,
            updated_at: now
          )
        end
        find_by_session_id(session_id)
      end

      def delete_by_session_id(session_id)
        return if session_id.nil? || session_id.empty?

        sessions.where(session_id: session_id).delete
      end

      private

      def next_id
        (sessions.max(:id) || 0) + 1
      end
    end
  end
end
