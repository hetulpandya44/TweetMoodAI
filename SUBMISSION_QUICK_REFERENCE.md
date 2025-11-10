# 📋 Quick Reference - Files for Professor Submission

## ✅ MUST INCLUDE (Essential Files)

### Source Code
- ✅ `app/` - Backend application (all `.py` files)
- ✅ `ui/` - Frontend application (all `.py` files)
- ✅ `scripts/` - All utility scripts (all `.py`, `.ps1`, `.bat`, `.sh` files)
- ✅ `tests/` - Test files (all `.py` files)
- ✅ `train.py` - Training script

### Configuration
- ✅ `requirements.txt` - Python dependencies
- ✅ `pytest.ini` - Test configuration
- ✅ `pyrightconfig.json` - Type checking
- ✅ `env.example` - Environment template (NOT `.env`)

### Docker
- ✅ `Dockerfile.backend` - Backend container
- ✅ `Dockerfile.frontend` - Frontend container
- ✅ `docker-compose.yml` - Docker Compose
- ✅ `.dockerignore` - Docker ignore rules (if exists)

### Deployment
- ✅ `render.yaml` - Deployment configuration
- ✅ `.github/workflows/ci.yml` - CI/CD pipeline

### Models
- ✅ `models/__init__.py`
- ✅ `models/README.md`
- ✅ `models/sentiment_model/config.json`
- ✅ `models/sentiment_model/label_map.json`
- ✅ `models/sentiment_model/tokenizer_config.json`
- ✅ `models/sentiment_model/vocab.txt`
- ✅ `models/sentiment_model/special_tokens_map.json`
- ✅ `models/sentiment_model/training_args.bin`
- ❓ `models/sentiment_model/model.safetensors` - **CHECK WITH PROFESSOR** (255 MB)

### Data
- ✅ `data/tweets_labeled.json`
- ✅ `data/tweets_snscrape.json`
- ✅ `data/tweets_snscrape_cleaned.json`

### Documentation
- ✅ `README.md`
- ✅ `PROJECT_REPORT.md`
- ✅ `PROJECT_STRUCTURE.md`
- ✅ `DEPLOYMENT_READY.md`
- ✅ All other `.md` files

---

## ❌ MUST EXCLUDE

- ❌ `venv/` - Virtual environment
- ❌ `__pycache__/` - Python cache
- ❌ `.env` - Secrets (use `env.example` instead)
- ❌ `logs/` - Log files
- ❌ `.vscode/`, `.idea/` - IDE files
- ❌ `.git/` - Git repository (usually)
- ❌ `models/checkpoints/` - Training checkpoints (too large)

---

## 🚀 Easy Way: Use the Script

### Option 1: Without Model Weights (Recommended - Smaller Size)
```powershell
cd scripts
.\prepare_submission.ps1
```

### Option 2: With Model Weights (Complete - 255 MB+)
```powershell
cd scripts
.\prepare_submission.ps1 -IncludeModelWeights
```

### Option 3: Complete with Everything
```powershell
cd scripts
.\prepare_submission.ps1 -IncludeModelWeights -IncludeCheckpoints -IncludeGitHistory
```

**Output**: Creates `TweetMoodAI_Submission/` folder in project root

---

## 📦 Manual Method

1. Create folder: `TweetMoodAI_Submission`
2. Copy all files from the "MUST INCLUDE" list above
3. **DO NOT** copy files from the "MUST EXCLUDE" list
4. Verify folder structure
5. Zip if needed

---

## 📊 File Size Guide

- **Without model weights**: ~5-10 MB
- **With model weights**: ~260 MB (255 MB model + other files)
- **With checkpoints**: ~500+ MB (not recommended)

**Recommendation**: Exclude model weights, provide download instructions separately

---

## ✅ Final Checklist

Before submitting:
- [ ] All source code included
- [ ] No `venv/` folder
- [ ] No `__pycache__/` folders
- [ ] No `.env` file (only `env.example`)
- [ ] `requirements.txt` included
- [ ] Documentation included
- [ ] Model config files included
- [ ] Decision made on model weights file
- [ ] README.md included

---

## 📝 Note for Professor

If model weights file (`model.safetensors` - 255 MB) is not included:
- All model configuration files are included
- Model can be rebuilt using `train.py`
- Or model can be downloaded separately if needed

---

**See `PROJECT_SUBMISSION_GUIDE.md` for complete details.**

