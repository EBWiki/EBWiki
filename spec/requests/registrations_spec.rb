# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Registrations', type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    ActionMailer::Base.perform_deliveries = true
    allow(AddUserToMailchimp).to receive(:call)
  end

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

      it "redirects to the users' home page" do
        expect(response).to redirect_to('/')
      end

      it 'creates a new user' do
        expect(User.last.name).to eq('Mark Nyon')
      end

      it 'sends one welcome email to the new user' do
        welcome_deliveries = ActionMailer::Base.deliveries.select do |mail|
          mail.subject == 'Welcome to EndBiasWiki'
        end
        expect(welcome_deliveries.size).to eq(1)
        expect(welcome_deliveries.first.to).to eq(['here@there.com'])
      end
    end

    context 'on failure with mismatched password' do
      before do
        allow(OnboardUser).to receive(:call)
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
        expect(response.status).to eq(200)
      end

      it 'displays an error message' do
        expect(response.body).to match('Please review the problems below')
      end

      it 'does not send email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'does not onboard the user' do
        expect(OnboardUser).not_to have_received(:call)
      end
    end

    context 'on failure with duplicate email' do
      before do
        create(:user, email: 'taken@example.com')
        allow(OnboardUser).to receive(:call)
        post user_registration_path, params: {
          user: {
            name: 'Another Person',
            email: 'taken@example.com',
            password: '12344321',
            password_confirmation: '12344321',
            subscribed: 0
          }
        }
      end

      it 'displays the registration form successfully' do
        expect(response.status).to eq(200)
      end

      it 'does not send email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'does not onboard the user' do
        expect(OnboardUser).not_to have_received(:call)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
