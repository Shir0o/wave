# Contributing to Wave

We welcome contributions to Wave! To ensure a smooth process, please follow these guidelines.

## Code of Conduct

Please maintain a respectful and welcoming environment when communicating with other project members.

## Getting Started

1. **Fork the Repository**: Create your own copy of the repository.
2. **Clone the Fork**: Clone it locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/wave.git
   ```
3. **Set Up Flutter**: Run `flutter pub get` and ensure the project builds on your simulator/device.

## Branching Model

- Create feature branches off the `main` branch.
- Use descriptive branch names: `feature/your-feature-name` or `bugfix/issue-description`.
- Make small, incremental commits with clear, descriptive commit messages.

## Pull Requests

1. **Run Tests**: Ensure all unit and widget tests pass before submitting your PR:
   ```bash
   flutter test
   ```
2. **Submit PR**: Open a pull request against the `main` branch of the upstream repository.
3. **Description**: Detail what changes you made, why they are necessary, and how they were verified.

## Code Style

- Adhere to the recommended Dart style guide (the default guidelines enforced in `analysis_options.yaml`).
- Format your code using `flutter format .` before committing.
