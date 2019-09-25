# frozen_string_literal: true

RSpec.describe 'Registrations', type: :request do
  describe 'POST /registrations' do
    context 'on success' do
      before do
        post user_registration_path, params: {
          user: {
            name: 'Mark Nyon',
            email: 'here@there.com',
            password: '12344321',
            password_confirmation: '12344321',
            subscribed: 0
          }
        }
      end

      it 'redirects to the users'' home page' do
        expect(response).to redirect_to('/users/mark-nyon')
      end

      it 'creates a new user' do
        expect(User.last.name).to eq('Mark Nyon')
      end
    end

    context 'on failure' do
      before do
        post user_registration_path, params: {
          user: {
            name: 'Mark Nyon',
            email: 'here@there.com',
            password: '12344321',
            password_confirmation: '123443211',
            subscribed: 0
          }
        }
      end

      it 'displays the registration form successfully' do
        expect(response.code).to eq '200'
      end

      it 'displays an error message' do
        expect(response.body).to match('Please review the problems below')
      end
    end
  end
end
