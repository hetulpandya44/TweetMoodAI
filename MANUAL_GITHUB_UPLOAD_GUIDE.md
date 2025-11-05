# Manual GitHub Upload Guide

**How to upload files to GitHub using the web interface (without git push)**

---

## 📋 Method 1: Upload Files via GitHub Web Interface

### Step 1: Create/Go to Repository

1. Go to https://github.com/new
2. Repository name: `TweetMoodAI`
3. Description: "AI-Powered Sentiment Analysis for Twitter Data"
4. Visibility: **Public** (required for free features)
5. **DO NOT** initialize with README, .gitignore, or license
6. Click **"Create repository"**

### Step 2: Upload Files

1. After creating the repository, you'll see a page with options
2. Click **"uploading an existing file"** link
3. Or go to: `https://github.com/hetulpandya44/TweetMoodAI/upload`

### Step 3: Select Files to Upload

**IMPORTANT**: Do NOT upload these large files:
- ❌ `models/checkpoints/` (entire directory)
- ❌ `models/sentiment_model/model.safetensors` (255 MB - too large)
- ❌ `models/sentiment_model/*.bin` (if any)
- ❌ `.git_backup_*` directories
- ❌ `venv/` directory
- ❌ `__pycache__/` directories

**Upload these files/folders**:
- ✅ `app/` (all Python files)
- ✅ `ui/` (all Python files)
- ✅ `tests/` (all test files)
- ✅ `scripts/` (all scripts)
- ✅ `models/sentiment_model/` (but exclude .safetensors and .bin files)
  - ✅ `config.json`
  - ✅ `label_map.json`
  - ✅ `tokenizer_config.json`
  - ✅ `vocab.txt`
  - ✅ `special_tokens_map.json`
  - ✅ `training_args.bin` (if < 100 MB)
- ✅ `data/` (excluding large files)
- ✅ `Dockerfile.backend`
- ✅ `Dockerfile.frontend`
- ✅ `docker-compose.yml`
- ✅ `requirements.txt`
- ✅ `README.md`
- ✅ `PROJECT_REPORT.md`
- ✅ All `.md` documentation files
- ✅ `.gitignore`
- ✅ `.github/workflows/ci.yml`
- ✅ `pytest.ini`
- ✅ `pyrightconfig.json`
- ✅ `env.example`
- ✅ `render.yaml`
- ✅ `render-backend.yaml`
- ✅ `render-frontend.yaml`

### Step 4: Drag and Drop or Select Files

1. **Drag and drop** files/folders into the upload area
2. Or click **"choose your files"** to browse
3. You can upload multiple files at once

### Step 5: Commit Changes

1. Scroll down to **"Commit changes"** section
2. Commit message: `Initial commit: TweetMoodAI - Complete Steps 8-13`
3. Description (optional):
   ```
   - FastAPI backend with sentiment analysis
   - Streamlit frontend with monitoring dashboard
   - Docker containerization
   - CI/CD pipeline
   - Cloud deployment ready
   - Complete documentation
   - All Steps 8-13 complete
   ```
4. Select **"Commit directly to the main branch"**
5. Click **"Commit changes"**

---

## 📋 Method 2: Create Files One by One (For Important Files)

If you want to create specific files manually:

1. Go to your repository: `https://github.com/hetulpandya44/TweetMoodAI`
2. Click **"Add file"** → **"Create new file"**
3. Enter file path (e.g., `app/main.py`)
4. Copy and paste file content
5. Click **"Commit new file"**

**Repeat for each file.**

---

## 📋 Method 3: Use GitHub Desktop (Easier Alternative)

### Install GitHub Desktop

1. Download: https://desktop.github.com/
2. Install and sign in with your GitHub account

### Clone Repository

1. In GitHub Desktop, click **"File"** → **"Clone repository"**
2. Select your repository: `TweetMoodAI`
3. Choose local path
4. Click **"Clone"**

### Add Files

1. Copy your project files to the cloned folder
2. **Remove large files** (checkpoints, .safetensors, etc.)
3. GitHub Desktop will show changed files
4. Add commit message
5. Click **"Commit to main"**
6. Click **"Push origin"**

---

## 📋 Method 4: Use Git Command Line (If HTTP 500 Fixed)

If you can fix the HTTP 500 error:

```powershell
# Increase HTTP buffer
git config http.postBuffer 524288000

# Try pushing again
git push origin main --force
```

---

## 🚨 Important: What NOT to Upload

### Large Files (Exceeds 100 MB):
- ❌ `models/checkpoints/checkpoint-60/model.safetensors` (255 MB)
- ❌ `models/checkpoints/checkpoint-60/optimizer.pt` (510 MB)
- ❌ `models/checkpoints/checkpoint-90/model.safetensors` (255 MB)
- ❌ `models/checkpoints/checkpoint-90/optimizer.pt` (510 MB)
- ❌ `models/sentiment_model/model.safetensors` (255 MB)

### Unnecessary Files:
- ❌ `.git_backup_*` directories
- ❌ `venv/` directory
- ❌ `__pycache__/` directories
- ❌ `*.pyc` files
- ❌ `.env` file (contains secrets)

---

## ✅ Recommended: Upload Structure

Upload these folders/files in this order:

```
TweetMoodAI/
├── app/                    ✅ Upload entire folder
├── ui/                     ✅ Upload entire folder
├── tests/                  ✅ Upload entire folder
├── scripts/                ✅ Upload entire folder (except .git_backup_*)
├── models/
│   ├── sentiment_model/
│   │   ├── config.json     ✅ Upload
│   │   ├── label_map.json  ✅ Upload
│   │   ├── tokenizer_config.json ✅ Upload
│   │   ├── vocab.txt       ✅ Upload
│   │   ├── special_tokens_map.json ✅ Upload
│   │   ├── training_args.bin ✅ Upload (if < 100 MB)
│   │   ├── model.safetensors ❌ SKIP (255 MB - too large)
│   │   └── *.bin           ❌ SKIP (if > 100 MB)
│   └── checkpoints/        ❌ SKIP entire folder
├── data/                   ✅ Upload (excluding large files)
├── .github/
│   └── workflows/
│       └── ci.yml          ✅ Upload
├── Dockerfile.backend      ✅ Upload
├── Dockerfile.frontend     ✅ Upload
├── docker-compose.yml      ✅ Upload
├── requirements.txt        ✅ Upload
├── README.md               ✅ Upload
├── PROJECT_REPORT.md       ✅ Upload
├── *.md                    ✅ Upload all documentation
├── .gitignore              ✅ Upload
├── pytest.ini              ✅ Upload
├── pyrightconfig.json      ✅ Upload
├── env.example             ✅ Upload
├── render.yaml             ✅ Upload
├── render-backend.yaml     ✅ Upload
└── render-frontend.yaml    ✅ Upload
```

---

## 📝 Step-by-Step: Upload via Web Interface

### 1. Go to Repository Upload Page

Visit: `https://github.com/hetulpandya44/TweetMoodAI/upload`

### 2. Upload Files

**Option A: Drag and Drop**
- Open File Explorer
- Navigate to `C:\Users\hetul\TweetMoodAI`
- Select folders/files (excluding large files)
- Drag and drop into GitHub upload area

**Option B: Click to Browse**
- Click **"choose your files"**
- Browse and select files
- Click **"Open"**

### 3. Add Commit Message

```
Initial commit: TweetMoodAI - Complete Steps 8-13
```

### 4. Commit

- Click **"Commit changes"**
- Wait for upload to complete

---

## 💡 Tips

1. **Upload in batches**: Upload important folders first (app/, ui/, tests/)
2. **Check file sizes**: Make sure no file exceeds 100 MB
3. **Use .gitignore**: After uploading, verify `.gitignore` is uploaded to prevent future issues
4. **Model file**: The model file (model.safetensors) is too large. You can:
   - Use Git LFS (requires setup)
   - Upload separately to cloud storage
   - Train on deployment server

---

## 🎯 Quick Checklist

Before uploading:
- [ ] Remove large files (> 100 MB)
- [ ] Remove checkpoints directory
- [ ] Remove .git_backup_* directories
- [ ] Remove venv/ directory
- [ ] Remove __pycache__/ directories
- [ ] Verify .gitignore is included
- [ ] Verify all source code is included
- [ ] Verify documentation is included

After uploading:
- [ ] Verify files are visible on GitHub
- [ ] Check that .gitignore is working
- [ ] Verify README.md displays correctly
- [ ] Test cloning the repository

---

## 🔗 Useful Links

- **GitHub Upload**: https://github.com/hetulpandya44/TweetMoodAI/upload
- **Repository**: https://github.com/hetulpandya44/TweetMoodAI
- **GitHub Desktop**: https://desktop.github.com/
- **Git LFS**: https://git-lfs.github.com/ (for large files)

---

**Last Updated**: 2025-11-05

