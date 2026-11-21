# frozen_string_literal: true

require_relative '../pre_commit_spec_helper'

RSpec.describe Ebwiki::PreCommit::Runner do
  def run_static(root)
    Ebwiki::PreCommit::Runner.new(repo_root: root).call
  end

  it 'passes a clean Ruby commit' do
    with_pre_commit_repo do |root|
      stage_file(root, 'clean.rb', "# frozen_string_literal: true\n\nmodule Clean\n  VERSION = '1'\nend\n")
      expect(run_static(root)).to be(true)
    end
  end

  it 'blocks a staged RuboCop offense' do
    with_pre_commit_repo do |root|
      stage_file(root, 'dirty.rb', "x=1\n")
      expect(run_static(root)).to be(false)
    end
  end

  it 'does not lint unstaged working-tree content when the index is clean' do
    with_pre_commit_repo do |root|
      stage_file(root, 'partial.rb', "# frozen_string_literal: true\n\nmodule Ok\n  VERSION = '1'\nend\n")
      write_file(root, 'partial.rb', "x=1\n")
      expect(run_static(root)).to be(true)
    end
  end

  it 'skips RuboCop and Brakeman for docs-only commits' do
    with_pre_commit_repo do |root|
      stage_file(root, 'docs/notes.md', "hello\n")
      expect(run_static(root)).to be(true)
    end
  end

  it 'blocks synthetic Brakeman findings not in the baseline' do
    with_pre_commit_repo do |root|
      write_file(root, 'config/routes.rb', "# frozen_string_literal: true\n\nRails.application.routes.draw { get 'x' => 'evil#index' }\n")
      write_file(root, 'app/controllers/evil_controller.rb', <<~RUBY)
        # frozen_string_literal: true

        class EvilController < ActionController::Base
          def index
            User.where(params[:clause])
          end
        end
      RUBY
      write_file(root, 'app/models/user.rb', "# frozen_string_literal: true\n\nclass User < ActiveRecord::Base\nend\n")
      run_git(root, 'add', 'config/routes.rb', 'app/controllers/evil_controller.rb', 'app/models/user.rb')
      expect(run_static(root)).to be(false)
    end
  end

  it 'handles paths with spaces' do
    with_pre_commit_repo do |root|
      stage_file(root, 'app/models/my stuff/widget.rb', "# frozen_string_literal: true\n\nmodule MyStuff\n  class Widget\n    VERSION = '1'\n  end\nend\n")
      expect(run_static(root)).to be(true)
    end
  end

  it 'handles renames without touching unstaged files' do
    with_pre_commit_repo do |root|
      stage_file(root, 'old_name.rb', "# frozen_string_literal: true\n\nmodule Renamed\n  VERSION = '1'\nend\n")
      run_git(root, 'mv', 'old_name.rb', 'new_name.rb')
      run_git(root, 'add', '-A')
      write_file(root, 'new_name.rb', "x=1\n")
      expect(run_static(root)).to be(true)
    end
  end
end

RSpec.describe Ebwiki::PullRequest::StyleSecurityDisclosure do
  it 'requires disclosure when rubocop config changes' do
    checker = described_class.new(
      body: "## Style/security rule changes\n\nNone\n",
      changed_files: ['.rubocop.yml']
    )
    expect(checker).not_to be_satisfied
  end

  it 'passes when disclosure is filled in' do
    checker = described_class.new(
      body: <<~BODY,
        ## Style/security rule changes

        Disabled Layout/LineLength for lib/legacy.rb because wrapping would harm readability.
      BODY
      changed_files: ['.rubocop.yml']
    )
    expect(checker).to be_satisfied
  end

  it 'passes when no rule files changed' do
    checker = described_class.new(body: '', changed_files: ['app/models/user.rb'])
    expect(checker).to be_satisfied
  end
end
