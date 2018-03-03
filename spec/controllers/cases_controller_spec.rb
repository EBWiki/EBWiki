# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end
  let(:cases) { FactoryBot.create_list(:case, 20) }

  describe '#index' do
    describe 'on success' do
      before(:each) { get :index }
      it 'assigns the first 12 cases to @cases' do
        expect(assigns(:cases)).to match_array cases[0..11]
      end
      it 'successfully returns the cases#index page' do
        expect(response).to be_success
      end
    end
    describe 'on failure' do
      before do
        def controller.index
          raise ActionController::InvalidAuthenticityToken
        end
      end
      describe 'index' do
        it 'does not raise an error' do
          expect { get :index }.not_to raise_error
        end
        it 'redirects to the home page' do
          expect(get(:index)).to redirect_to('/')
        end
      end
    end
  end
end

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end
  let(:cases) { FactoryBot.create_list(:case, 20) }

  describe '#show' do
    context 'when requested case exists' do
      let(:this_case) { cases.first }
      before(:each) { get :show, id: this_case.id }
      it 'success' do
        expect(response).to be_success
      end
      it 'assigns it to @case' do
        expect(assigns(:case)).to eq this_case
      end
    end
    context 'when requested case does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { get :show, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end
  let(:cases) { FactoryBot.create_list(:case, 20) }
  describe '#create' do
    login_user
    context 'when valid' do
      let(:case_attrs) { FactoryBot.attributes_for(:case, state_id: 33) }
      let(:subject_attrs) { FactoryBot.attributes_for(:subject) }
      it 'success' do
        allow_any_instance_of(Case).to receive(:full_address).and_return('Albany NY')
        case_attrs['subjects_attributes'] = { '0' => subject_attrs }
        post :create, 'case': case_attrs
        expect(response).to redirect_to(case_path(Case.last))
      end
      it 'saves and assigns new case to @case' do
        allow_any_instance_of(Case).to receive(:full_address).and_return('Albany NY')
        case_attrs['subjects_attributes'] = { '0' => subject_attrs }
        post :create, 'case': case_attrs
        expect(assigns(:case)).to be_a_kind_of(Case)
        expect(assigns(:case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:case_attrs) { attributes_for(:invalid_case) }
      it 'fails' do
        allow_any_instance_of(Case).to receive(:full_address).and_return(' Albany NY ')
        post :create, 'case': case_attrs
        expect(response).to render_template(:new)
      end
    end
  end
end

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end

  let(:cases) { FactoryBot.create_list(:case, 20) }
  describe '#update' do
    login_user
    let(:this_case) { create(:case) }
    context 'when valid' do
      let(:new_values) {
        {
          overview: 'new overview',
          city: 'Buffalo',
          summary: 'A summary of changes'
        }
      }
      it 'success' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(response).to redirect_to(case_path(Case.last))
      end
      it 'saves and assigns case to @case' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(assigns(:case)).to be_a_kind_of(Case)
        expect(assigns(:case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:new_values) { attributes_for(:invalid_case) }
      it 'redirects to the edit page' do
        patch :update, id: this_case.id, case: new_values
        expect(response).to render_template(:edit)
      end
    end
  end
end

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end

  let(:cases) { FactoryBot.create_list(:case, 20) }
  describe '#destroy' do
    login_user
    context 'when requested case exists' do
      let(:this_case) { cases[rand 4] }
      before(:each) { delete :destroy, id: this_case.id }
      it 'success' do
        expect(response).to redirect_to(root_path)
      end
      it 'removes case form DB' do
        expect(Case.all).not_to include this_case
        expect { this_case.reload }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
    context 'when requested case does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { delete :destroy, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
