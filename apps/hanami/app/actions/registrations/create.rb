# frozen_string_literal: true

module EbWiki
  module Actions
    module Registrations
      class Create < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          email = request.params[:email].to_s.strip
          name = request.params[:name].to_s.strip
          password = request.params[:password].to_s
          errors = []
          errors << "Name is required" if name.empty?
          errors << "Email is required" if email.empty?
          errors << "Password must be at least 8 characters" if password.length < 8
          errors << "That email is already registered" if user_repo.by_email(email)

          if errors.any?
            response.status = 422
            response.render view, errors: errors, values: {email: email, name: name}
            return
          end

          user_repo.register(email: email, password: password, name: name)
          response.redirect_to "/login?registered=1"
        end
      end
    end
  end
end
