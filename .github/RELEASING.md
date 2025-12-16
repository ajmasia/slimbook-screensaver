# Releasing

This project uses GitHub Actions to automate releases.

## How to create a new release

1. **Merge changes to main**
   ```bash
   git checkout main
   git merge develop
   git push origin main
   ```

2. **Update version**
   ```bash
   # Edit VERSION file with new version number
   # Edit README.md badge version
   git add VERSION README.md
   git commit -m "Bump version to X.Y.Z"
   git push origin main
   ```

3. **Create and push tag**
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

4. **Done!** GitHub Action automatically:
   - Generates changelog from commits since previous tag
   - Creates release with installation instructions

## Version format

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backward compatible
- **PATCH** (0.0.X): Bug fixes, backward compatible

## Commit messages

Write clear commit messages - they become the changelog:
- `Add feature X` - New functionality
- `Fix bug in Y` - Bug fix
- `Update Z documentation` - Docs changes
- `Refactor W` - Code improvements

Avoid merge commits in changelog by using `--no-merges` filter.
