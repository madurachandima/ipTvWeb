# GitHub Pages Deployment Guide

To host your IPTV Web app on GitHub Pages, follow these steps:

## 1. Create a GitHub Repository
If you haven't already, create a new repository on GitHub (e.g., `iptv-web`).

## 2. Initialize Git and Push Code
Run these commands in your project root:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

## 3. Build the Production App
GitHub Pages usually hosts at `https://<username>.github.io/<repo-name>/`. You must set the correct `base-href`:
```bash
flutter build web --release --base-href "/YOUR_REPO_NAME/"
```
> [!IMPORTANT]
> Replace `YOUR_REPO_NAME` with your actual repository name (e.g., `iptv-web`).

## 4. Deploy to GitHub Pages
The easiest way is using the `gh-pages` package:
```bash
# Install the package
flutter pub add --dev gh_pages

# Deploy the build/web directory
flutter pub run gh_pages:deploy --directory build/web
```

## 5. Enable GitHub Pages
1. Go to your repository on GitHub.
2. Navigate to **Settings > Pages**.
3. Under **Build and deployment**, ensure the source is set to **Deploy from a branch**.
4. Select the `gh-pages` branch and click **Save**.

Your app will be live at `https://<username>.github.io/<repo-name>/` in a few minutes!
