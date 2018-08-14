# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasesController, type: :controller do
  # Stubbing out make_undo_link for all specs
  before do
    allow_any_instance_of(CasesController).to receive(
      :make_undo_link
    ).and_return('/cases/1')
  end

  describe '#index' do
    describe 'on success' do
      let(:cases) { FactoryBot.create_list(:case, 20) }
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
      it 'does not raise an error' do
        expect { get :index }.not_to raise_error
      end
      it 'redirects to the home page' do
        expect(get(:index)).to redirect_to('/')
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
        expect(assigns(:this_case)).to eq this_case
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
      let(:link_attrs) { FactoryBot.attributes_for(:link) }
      it 'saves the new case & redirects to show the case created' do
        allow_any_instance_of(Case).to receive(:full_address).and_return('Albany NY')
        case_attrs['subjects_attributes'] = { '0' => subject_attrs }
        case_attrs['links_attributes'] = { '0' => link_attrs }
        post :create, 'case': case_attrs
        expect(response).to redirect_to(case_path(Case.last))
      end
      it 'saves and assigns new case to @case' do
        allow_any_instance_of(Case).to receive(:full_address).and_return('Albany NY')
        case_attrs['subjects_attributes'] = { '0' => subject_attrs }
        case_attrs['links_attributes'] = { '0' => link_attrs }
        post :create, 'case': case_attrs
        expect(assigns(:this_case)).to be_a_kind_of(Case)
        expect(assigns(:this_case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:case_attrs) { attributes_for(:invalid_case) }
      it 'fails' do
        allow_any_instance_of(Case).to receive(:full_address).and_return(' Albany NY ')
        post :create, 'case': case_attrs
        expect(assigns(:categories)).to match_array([])
        expect(assigns(:states)).to match_array([])
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
      let(:new_values) do
        {
          overview: 'new overview',
          city: 'Buffalo',
          summary: 'A summary of changes'
        }
      end
      it 'success' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(response).to redirect_to(case_path(this_case))
      end
      it 'saves and assigns case to @case' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(assigns(:this_case)).to be_a_kind_of(Case)
        expect(assigns(:this_case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:new_values) { attributes_for(:invalid_case) }
      before(:each) do 
        patch :update, id: this_case.id, case: new_values
      end
      it 'redirects to the edit page' do
        expect(response).to render_template(:edit)
      end
      
       it 'has a non-empty set of categories' do
        expect(assigns['categories']).to_not be_nil
      end
      
      it 'has a non-empty set of states' do
        expect(assigns['states']).to_not be_nil
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
      it 'returns a message that says that that case was not foun' do
        expect(delete :destroy, id: -1).to redirect_to root_path
        expect(flash[:notice]).to eq(I18n.t('cases_controller.case_not_found_message'))
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


  describe '#history', versioning: true do
    login_user
    let(:this_case) { FactoryBot.create(:case) }
    context 'when requested case exists' do

      it 'shows the history page' do
        this_case.update_attributes title: 'Updated Title'
        get :history, id: this_case.id
        expect(response).to render_template(:history)
      end

    end
    context 'when requested case does not exists' do
      it 'shows the history page with no history' do
        get :history, id: -1
        expect(response).to render_template(:history)
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


  describe '#history', versioning: true do
    login_user
    let(:this_case) { FactoryBot.create(:case) }
    context 'when requested case exists' do

      it 'shows the history page' do
        this_case.update_attributes title: 'Updated Title'
        get :history, id: this_case.id
        expect(response).to render_template(:history)
      end

    end
    context 'when requested case does not exists' do
      it 'shows the history page with no history' do
        get :history, id: -1
        expect(response).to render_template(:history)
      end
    end
  end
end
