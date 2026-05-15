# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## 0.5.0 - 2026-05-16

### Added
- Adapters for popular Ruby paginators, each loaded automatically when the
  matching gem is already required:
  - **Kaminari**: `ActiveRecord::Relation#estimate_page` pre-populates
    `total_count` so Kaminari skips its own `COUNT(*)` query.
  - **will_paginate**: `ActiveRecord::Relation#estimate_paginate` passes the
    estimate as `:total_entries` so will_paginate skips its count query.
  - **Pagy**: `Pagy::Backend#pagy_estimate` injects the estimate as `:count`
    so Pagy skips its count query.
  All three accept a `threshold:` option that is forwarded to
  `#estimate_count`. Class-level callers (e.g. `User.estimate_page(1)`) are
  also supported.
- CI matrix testing against ActiveRecord 7.0, 7.1, 7.2, 8.0 and 8.1.

### Changed
- Minimum supported Ruby is now 3.1.0 (was 2.6.0).

## 0.4.0 - 2020-05-21

### Removed
- No longer depends on `pry` gem for production

## 0.3.0 - 2021-04-20

### Added
- MySQL support
- Tests for PostgreSQL and MySQL

## 0.1.0 - 2021-03-04

### Added
- Initial release
- `#estimate_count` method for `ActiveRecord::Relation` class, PostgreSQL version
