RSpec.describe 'Registrations', type: :request do
  describe 'POST /registrations' do
    it 'works! (now write some real specs)' do
      get '/'
      expect(response).to render_template('index')
      
      post user_registration_path, user: {
          name: 'Mark Nyon',
          email: 'here@there.com',
          password: '12344321',
          password_confirmation: '123443211',
          subscribed: 0
      }
      expect(response).to have_http_status(200)
    end
  end
end

