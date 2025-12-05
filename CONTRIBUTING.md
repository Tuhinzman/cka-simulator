# Contributing to CKA Simulator

First off, thank you for considering contributing to CKA Simulator! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Descriptive title**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Environment details** (OS, Terraform version, AWS region)
- **Logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear description** of the enhancement
- **Use cases** for the feature
- **Possible implementation** approach

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Make your changes
3. Test your changes thoroughly
4. Update documentation if needed
5. Ensure the code follows existing style
6. Write clear commit messages
7. Submit a pull request

## Development Setup
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/cka-simulator.git
cd cka-simulator

# Create a branch
git checkout -b feature/my-new-feature

# Make changes and test
cd terraform
terraform init
terraform plan

# Commit and push
git add .
git commit -m "Add: Description of changes"
git push origin feature/my-new-feature
```

## Code Style

- Use clear, descriptive variable names
- Comment complex logic
- Follow Terraform best practices
- Keep scripts modular and reusable

## Questions?

Feel free to open an issue for any questions!

Thank you! 🙏
