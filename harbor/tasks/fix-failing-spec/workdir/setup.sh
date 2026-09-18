#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki
bundle exec rails db:prepare

mkdir -p spec/harbor

cat > lib/harbor_addition.rb <<'RUBY'
# frozen_string_literal: true

# Intentionally wrong — the agent must fix this so the spec is green.
module HarborAddition
  def self.add(left, right)
    left + right + 1
  end
end
RUBY

cat > spec/harbor/addition_spec.rb <<'RUBY'
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HarborAddition do
  it 'adds two integers' do
    expect(HarborAddition.add(2, 2)).to eq(4)
  end
end
RUBY
