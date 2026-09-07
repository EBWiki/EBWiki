# Recommended Additional Tests for EBWiki

This document outlines recommended test coverage improvements to ensure EBWiki maintains reliability when gems are upgraded through the automated Dependabot workflow.

## Current Test Infrastructure

The project currently has:
- **Test Framework**: RSpec with shoulda-matchers and FactoryBot
- **Current Coverage**: ~2,921 lines of test code across multiple test directories
- **CI Environment**: Ruby 3.4.2, PostgreSQL 17, Redis, and Elasticsearch 6.8.13
- **CI Checks**: RSpec, Brakeman (security), Rubocop (linting), and Markdown link checking

## Recommended Test Coverage Areas

### 1. Critical Path Tests (High Priority)

These tests ensure core functionality remains intact after dependency updates:

#### 1.1 User Authentication & Authorization Workflow
- [ ] Sign up flow with email verification
- [ ] Login with email and password
- [ ] Password reset workflow
- [ ] Session management and timeout
- [ ] Role-based access control (admin, moderator, contributor, viewer)
- [ ] Permission inheritance for nested resources
- [ ] Authentication failure scenarios (invalid credentials, expired tokens)

**Why**: Authentication/authorization changes in gem updates (Devise, Pundit, etc.) can break user workflows.

#### 1.2 Case/Article Management Workflows
- [ ] Create case with required fields
- [ ] Create case with optional fields
- [ ] Edit case and verify updates propagate
- [ ] Delete case and verify cleanup
- [ ] Bulk case operations (if applicable)
- [ ] Case visibility based on user role
- [ ] Draft vs. published case states

**Why**: Core domain functionality must survive dependency updates to data models and associations.

#### 1.3 Search Functionality
- [ ] Search for cases by keyword
- [ ] Search with filters (date range, agency, location)
- [ ] Search pagination
- [ ] Search with special characters
- [ ] Empty search results handling
- [ ] Elasticsearch fallback/recovery if service unavailable

**Why**: Elasticsearch-related gem updates can break search functionality silently.

#### 1.4 Notification & Messaging System
- [ ] User receives email notifications
- [ ] Email is sent with correct content
- [ ] Message delivery retry on failure
- [ ] Unsubscribe/preference management

**Why**: Mailer gem updates can break email delivery without obvious errors.

### 2. Integration Tests (High Priority)

These tests verify cross-service communication:

#### 2.1 Elasticsearch Integration
- [ ] Case indexing on creation
- [ ] Case reindexing on update
- [ ] Case removal from index on delete
- [ ] Index consistency with database
- [ ] Search performance with large datasets
- [ ] Index recovery/reindexing script execution

**Why**: Elasticsearch client gem upgrades are common and can silently fail.

#### 2.2 Redis Integration
- [ ] Caching stores and retrieves data
- [ ] Cache invalidation on data update
- [ ] Session storage in Redis
- [ ] Background job queueing (if used)
- [ ] Redis connection failure recovery

**Why**: Redis gem updates can change serialization/deserialization behavior.

#### 2.3 Database Integration
- [ ] Multi-step transactions complete successfully
- [ ] Transaction rollback on error
- [ ] Foreign key constraints enforced
- [ ] Concurrent access to same record handles correctly
- [ ] Database migration compatibility

**Why**: ActiveRecord and Postgres gem updates can affect transaction handling.

#### 2.4 External API Integrations (if applicable)
- [ ] AWS S3 file upload/download
- [ ] Third-party API authentication
- [ ] API error handling and retry logic
- [ ] Rate limiting compliance

**Why**: AWS SDK and HTTP client gem updates can break external integrations.

### 3. Edge Cases & Error Handling (Medium Priority)

These tests ensure robustness across various scenarios:

#### 3.1 Boundary Conditions
- [ ] Large dataset handling (pagination, memory)
- [ ] Special characters in text fields (XSS prevention)
- [ ] Unicode and non-ASCII characters
- [ ] Empty/null field validation
- [ ] Maximum field length enforcement

**Why**: Gem updates can change validation or sanitization behavior.

#### 3.2 Concurrent Operations
- [ ] Simultaneous edits to same case
- [ ] Race conditions in counter increments
- [ ] Lock timeout scenarios
- [ ] Conflicting updates resolution

**Why**: Concurrency-related gems or Rails updates can expose race conditions.

#### 3.3 Error Recovery
- [ ] 500 error pages render correctly
- [ ] Database connection loss recovery
- [ ] Timeout handling for slow operations
- [ ] Graceful degradation when Redis unavailable
- [ ] Graceful degradation when Elasticsearch unavailable

**Why**: Error handling gems and middleware updates can change error flow.

### 4. Performance & Stability Tests (Medium Priority)

These tests catch performance regressions from gem updates:

#### 4.1 Response Time Benchmarks
- [ ] Homepage load time
- [ ] Search query response time
- [ ] Case detail page load time
- [ ] API endpoint response time (if applicable)

**Why**: Gem updates can introduce performance regressions that aren't caught by functional tests.

#### 4.2 Query Optimization
- [ ] N+1 query detection on case index
- [ ] N+1 query detection on case show
- [ ] Query count stability after updates
- [ ] Memory usage per request

**Why**: Gem updates can affect ActiveRecord query generation.

#### 4.3 Load Testing
- [ ] Concurrent user handling
- [ ] Memory usage under load
- [ ] Connection pool exhaustion handling

**Why**: Gem updates related to threading or connection management can fail under load.

### 5. Dependency-Specific Tests (High Priority)

These tests target known problem areas when gems update:

#### 5.1 Rails Framework Updates
- [ ] ActiveRecord associations still work
- [ ] ActionController routes match expectations
- [ ] ActionView template rendering
- [ ] Middleware chain execution order
- [ ] Cookie/session handling

#### 5.2 Authentication Gem Updates (Devise)
- [ ] Devise password validation rules
- [ ] OTP if two-factor auth is used
- [ ] Token expiration and refresh
- [ ] Password strength requirements

#### 5.3 Authorization Gem Updates (Pundit)
- [ ] Policy scope filtering works
- [ ] Admin policies override others
- [ ] Role-based policies function correctly

#### 5.4 Database Gem Updates (ActiveRecord)
- [ ] Enum handling (if used)
- [ ] JSON column queries (if used)
- [ ] Relationship loading strategies

#### 5.5 Serialization Gems
- [ ] JSON serialization format consistency
- [ ] Nested resource serialization
- [ ] Date/time format in API responses

**Why**: Major gem updates often include breaking changes in these core areas.

## Implementation Priority

### Phase 1 (Critical - Implement First)
1. Critical path tests (sections 1.1-1.4)
2. Elasticsearch integration tests
3. Database integration tests

### Phase 2 (Important - Implement Second)
1. Redis integration tests
2. Edge case and error handling tests
3. Dependency-specific tests for Rails, Devise, Pundit

### Phase 3 (Valuable - Implement Third)
1. Performance benchmarks
2. Concurrent operation tests
3. Load testing

## Testing Best Practices

### Using Existing Test Infrastructure
- Use FactoryBot for test data creation
- Use shoulda-matchers for model validation testing
- Use RSpec shared examples for common test patterns
- Organize tests by domain (requests, models, services, etc.)

### New Test Patterns to Introduce
- Use `shared_context` for common setup across related tests
- Document complex test scenarios with comments
- Use descriptive test names that explain the scenario
- Consider using `test-prof` gem for N+1 query detection
- Consider using `rack-mini-profiler` for performance testing

### Continuous Integration Considerations
- Tests should run in < 5 minutes
- Parallel test execution can speed up test runs
- Database isolation between tests (already done by Rails)
- Use test-specific seeds for reproducible results

## Monitoring Test Quality

1. **Code Coverage**: Track coverage percentage (target: >80% for critical paths)
2. **Test Failure Rate**: Monitor false positives
3. **Test Duration**: Track total CI pipeline time
4. **Gem Update Safety**: Document any gems that require special testing attention

## Updating This Document

When a gem update causes an issue:
1. Add a new regression test to catch it in the future
2. Document the issue in this file under "Known Sensitivities"
3. Update the Dependabot auto-merge workflow if needed

---

**Last Updated**: 2026-05-27  
**Next Review**: When significant gems are updated (Rails, Devise, Pundit, ActiveRecord plugins)
