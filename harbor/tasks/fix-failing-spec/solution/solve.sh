#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki

cat > lib/harbor_addition.rb <<'RUBY'
# frozen_string_literal: true

module HarborAddition
  def self.add(left, right)
    left + right
  end
end
RUBY
