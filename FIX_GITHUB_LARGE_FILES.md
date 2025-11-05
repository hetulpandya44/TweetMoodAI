# Fix GitHub Large Files Error - Complete Guide

**Problem**: GitHub rejects push because large checkpoint files are in git history.

---

## 🚨 The Issue

Even though we removed the files from the current commit, they're still in git history. GitHub checks the entire history when you push, not just the current commit.

---

## ✅ Solution Options

### Option 1: Remove from History (Recommended if you have git-filter-branch)

**Best for**: If you want to keep your commit history but remove large files.

```powershell
# Run the script
powershell -ExecutionPolicy Bypass -File scripts\remove_large_files_from_history.ps1
```

**Then force push:**
```powershell
git push origin main --force
```

⚠️ **Warning**: Force push overwrites remote history. Make sure no one else is working on the same branch.

---

### Option 2: Fresh Repository (Safest - Recommended)

**Best for**: If you haven't shared the repository much or want a clean start.

This creates a completely new git repository without the large files in history.

```powershell
# Run the script
powershell -ExecutionPolicy Bypass -File scripts\alternative_fresh_repo.ps1
```

**Then add remote and force push:**
```powershell
# Add remote (if not already added)
git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git

# Force push (overwrites remote)
git push origin main --force
```

⚠️ **Warning**: This creates a new repository. You'll lose commit history, but it's the cleanest solution.

---

### Option 3: Manual Git Filter-Branch

If the scripts don't work, try manually:

```powershell
# Remove files from all commits
git filter-branch --force --index-filter "git rm -rf --cached --ignore-unmatch models/checkpoints/checkpoint-60 models/checkpoints/checkpoint-90" --prune-empty --tag-name-filter cat -- --all

# Clean up
Remove-Item -Path .git/refs/original -Recurse -Force -ErrorAction SilentlyContinue
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin main --force
```

---

### Option 4: Use Git LFS (Git Large File Storage)

If you really need to keep the checkpoint files in git:

```powershell
# Install Git LFS (if not installed)
# Download from: https://git-lfs.github.com/

# Initialize Git LFS
git lfs install

# Track large files
git lfs track "models/checkpoints/**/*.safetensors"
git lfs track "models/checkpoints/**/*.pt"

# Add .gitattributes
git add .gitattributes

# Commit and push
git commit -m "Add Git LFS tracking"
git push origin main
```

**Note**: Git LFS requires a GitHub account with LFS quota. Free tier has limited storage.

---

## 🎯 Recommended: Option 2 (Fresh Repository)

Since you're working on this project yourself and haven't shared it much, **Option 2 is the safest and cleanest**:

1. **Run the script**: `scripts/alternative_fresh_repo.ps1`
2. **Add remote**: `git remote add origin https://github.com/hetulpandya44/TweetMoodAI.git`
3. **Force push**: `git push origin main --force`

This gives you a clean repository without any large files in history.

---

## ✅ Verification

After pushing, verify the files are gone:

```powershell
# Check repository size
git count-objects -vH

# Check if large files are in history
git log --all --full-history -- models/checkpoints/

# Should return nothing if files are removed
```

---

## 📝 What Happens

- ✅ Large checkpoint files removed from git history
- ✅ Only final trained model remains (in `models/sentiment_model/`)
- ✅ All source code and documentation preserved
- ✅ Clean repository ready for GitHub

---

## 🔧 Troubleshooting

### If force push is rejected:

You may need to enable force push in GitHub settings, or use:

```powershell
git push origin main --force-with-lease
```

### If you get "remote: Repository not found":

Make sure the remote URL is correct:
```powershell
git remote -v
git remote set-url origin https://github.com/hetulpandya44/TweetMoodAI.git
```

---

## 💡 Tips

- **Backup first**: The scripts create backups, but you can also manually backup `.git` folder
- **Check local files**: The checkpoint files are still on your local machine (just not in git)
- **Only final model needed**: For deployment, you only need the final trained model
- **Clean history**: A fresh repository gives you a clean start

---

**Last Updated**: 2025-11-03

