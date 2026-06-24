# Changelog

## [1.0.1](https://github.com/venky1912/venky-terraform-module-iam/compare/v1.0.0...v1.0.1) (2026-06-24)


### Bug Fixes

* pin provider versions to supported range ([#3](https://github.com/venky1912/venky-terraform-module-iam/issues/3)) ([edb87bf](https://github.com/venky1912/venky-terraform-module-iam/commit/edb87bf72cec793bab1f1f6600cc34ba1a6721c2))

## [1.0.0](https://github.com/venky1912/venky-terraform-module-iam/compare/v0.1.1...v1.0.0) (2026-06-24)


### ⚠ BREAKING CHANGES

* Module interface completely redesigned.
    - Generic roles with configurable trust policies (any service)
    - Custom IAM policy creation
    - Instance profiles for EC2-based workloads
    - OIDC providers (EKS, GitHub Actions, GitLab CI, etc.)
    - Federated roles (IRSA, GitHub OIDC, any web identity)

### Features

* refactor to generic IAM module for any workload ([1e960fe](https://github.com/venky1912/venky-terraform-module-iam/commit/1e960fef0ef2ca1844de8c8b5922b2771d6e3ccf))

## [0.1.1](https://github.com/venky1912/venky-terraform-module-iam/compare/v0.1.0...v0.1.1) (2026-06-24)


### Bug Fixes

* improve module documentation header ([3cf0000](https://github.com/venky1912/venky-terraform-module-iam/commit/3cf0000eebbc48d1d6a3f263ad723b6d7e772a55))

## [0.1.0] - 2026-06-24

### Added

- Initial release
- EKS cluster IAM role with managed policies
- EKS node group IAM role with instance profile
- IAM OIDC provider for IRSA
- Configurable IRSA roles with namespace/service account scoping
- Additional policy attachment support
