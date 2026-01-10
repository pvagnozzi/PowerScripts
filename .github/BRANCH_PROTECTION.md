# 🛡️ Branch Protection Configuration

## Overview

This document explains how to configure branch protection rules for the `main` and `dev` branches to ensure all changes go through Pull Requests.

## 🎯 Protected Branches

The following branches are protected and require Pull Requests:

- `main` - Production-ready code
- `dev` - Development/integration branch

## ⚙️ Configuring Branch Protection on GitHub

### Step 1: Access Repository Settings

1. Navigate to your repository on GitHub
2. Click on **Settings** (top right)
3. In the left sidebar, click on **Branches** under "Code and automation"

### Step 2: Add Branch Protection Rule for `main`

1. Click **Add branch protection rule**
2. In **Branch name pattern**, enter: `main`
3. Configure the following settings:

#### Required Settings ✅

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1` (or more as needed)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners (optional, if you have CODEOWNERS file)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Select required status checks:
    - `Block Direct Push to Protected Branches`
    - `Validate Pull Request`
    - `Quality Checks`
    - `Cross-Platform Consistency Check`
    - `PR Metadata Check`
    - `File Structure Validation`

- ✅ **Require conversation resolution before merging**
  - Ensures all PR comments are addressed

- ✅ **Require linear history** (optional but recommended)
  - Prevents merge commits, keeps history clean

- ✅ **Do not allow bypassing the above settings**
  - Applies to administrators too

#### Additional Recommended Settings 📝

- ✅ **Include administrators**
  - Even admins must follow the PR process

- ✅ **Restrict who can push to matching branches**
  - Leave empty to block all direct pushes
  - Or specify users/teams who can push (not recommended)

- ✅ **Allow force pushes**: **Disabled**

- ✅ **Allow deletions**: **Disabled**

4. Click **Create** to save the rule

### Step 3: Add Branch Protection Rule for `dev`

Repeat Step 2 with the following changes:

1. **Branch name pattern**: `dev`
2. Use the same settings as `main`, but you may choose to:
   - Require fewer approvals (e.g., 1 approval)
   - Allow more flexibility for the development branch

## 🔄 Workflow

### For Contributors

1. **Create a feature branch** from `dev`:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request**:
   - Go to GitHub repository
   - Click **Pull requests** → **New pull request**
   - Select `dev` as base branch
   - Select your feature branch as compare branch
   - Fill in PR template and create PR

4. **Wait for reviews and checks**:
   - All automated checks must pass
   - Required reviewers must approve
   - Address any feedback

5. **Merge the PR** (when approved):
   - Use **Squash and merge** for clean history

### Releasing to Main

1. **Create a release PR** from `dev` to `main`:
   ```bash
   git checkout -b release/v1.0.0
   # Update CHANGELOG.md, version numbers, etc.
   git commit -m "chore: prepare release v1.0.0"
   git push origin release/v1.0.0
   ```

2. **Create PR** targeting `main`

3. **After approval and merge**, create a GitHub release/tag

## 🚫 What Happens If You Try to Push Directly?

If you attempt to push directly to `main` or `dev`:

```bash
$ git push origin main
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: At least 1 approving review is required by reviewers with write access.
To https://github.com/pvagnozzi/PowerScripts.git
 ! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'https://github.com/pvagnozzi/PowerScripts.git'
```

Additionally, the **Branch Protection Check** workflow will fail with:
```
❌ Direct pushes to main are not allowed!
ℹ️ Please create a Pull Request instead.
```

## 🔍 Automated Checks

The following GitHub Actions workflows run on every PR:

### 1. Branch Protection Check (`branch-protection.yml`)
- ❌ Blocks direct pushes to protected branches
- ✅ Validates Pull Requests
- 🔍 Runs quality checks
- 🔄 Checks cross-platform consistency

### 2. PR Checks (`pr-checks.yml`)
- 📋 Validates PR metadata and title format
- 📁 Checks file structure and naming conventions
- 📚 Ensures documentation is updated
- 📏 Analyzes PR size

## 📝 Best Practices

1. ✅ **Always create a feature branch** - Never work directly on `main` or `dev`
2. ✅ **Keep PRs small** - Easier to review and less likely to have conflicts
3. ✅ **Write meaningful commit messages** - Use conventional commits format
4. ✅ **Update documentation** - Keep README.md in sync with code changes
5. ✅ **Test locally first** - Run scripts on target platform before pushing
6. ✅ **Request reviews early** - Don't wait until PR is "perfect"
7. ✅ **Address feedback promptly** - Keep the PR moving forward
8. ✅ **Update cross-platform scripts together** - Maintain consistency

## 🆘 Troubleshooting

### "Protected branch update failed"
- **Solution**: Create a Pull Request instead of pushing directly

### "Required status check is failing"
- **Solution**: Check the workflow logs and fix the issues
- Common issues:
  - Naming convention violations
  - Missing cross-platform updates
  - Documentation not updated

### "Pull request reviews required"
- **Solution**: Wait for reviewer approval or request a review

### Need to make an urgent hotfix?
1. Create a hotfix branch from `main`
2. Make the minimal necessary changes
3. Create PR with `hotfix:` prefix
4. Request urgent review
5. Merge after approval

## 🔗 Additional Resources

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Workflows](https://docs.github.com/en/actions/using-workflows)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [PowerScripts Contributing Guide](../CONTRIBUTING.md)

## 🎯 Summary

With these branch protection rules in place:

- ✅ All changes to `main` and `dev` must go through Pull Requests
- ✅ Automated checks ensure code quality and consistency
- ✅ Reviews ensure knowledge sharing and catch issues early
- ✅ History remains clean and traceable
- ✅ Collaboration is enforced and encouraged

---

**Questions or issues?** Open an issue or discussion on GitHub!
