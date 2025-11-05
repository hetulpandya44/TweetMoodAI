# Fix GitHub HTTP 500 Error

**Error**: `RPC failed; HTTP 500 curl 22 The requested URL returned error: 500`

This is a **GitHub server-side error**, not a local issue. Here are solutions:

---

## 🔍 Quick Diagnosis

### Check GitHub Status
1. Visit: https://www.githubstatus.com
2. Check if GitHub is experiencing issues
3. If GitHub is down, wait and retry later

---

## ✅ Solution 1: Increase HTTP Buffer (Most Common Fix)

The error often occurs when pushing large repositories. Increase the HTTP buffer:

```powershell
# Increase HTTP post buffer to 500 MB
git config http.postBuffer 524288000

# Try pushing again
git push origin main --force
```

---

## ✅ Solution 2: Use SSH Instead of HTTPS

If HTTPS is having issues, switch to SSH:

```powershell
# Change remote URL to SSH
git remote set-url origin git@github.com:hetulpandya44/TweetMoodAI.git

# Push again
git push origin main --force
```

**Note**: You need SSH keys set up for this. If not, use Solution 1.

---

## ✅ Solution 3: Verify No Large Files

Make sure no large files are being pushed:

```powershell
# Check for large files
git ls-files | ForEach-Object {
    if (Test-Path $_) {
        $file = Get-Item $_
        if ($file.Length -gt 100MB) {
            Write-Host "$_ : $([math]::Round($file.Length/1MB, 2)) MB"
        }
    }
}
```

If large files are found, ensure they're in `.gitignore` and remove them from staging:

```powershell
# Remove large files from staging
git reset HEAD <large-file-path>

# Commit again
git commit -m "Remove large files"
git push origin main --force
```

---

## ✅ Solution 4: Create Fresh Repository

If the error persists, create a fresh repository (removes any corrupted history):

```powershell
# Run the fix script
powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1

# Then push
git push origin main --force
```

---

## ✅ Solution 5: Push in Smaller Chunks

If the repository is large, try pushing with verbose output:

```powershell
# Push with verbose output to see where it fails
git push origin main --force --verbose
```

---

## 🔧 Additional Troubleshooting

### Check Network Connection
```powershell
# Test GitHub connectivity
ping github.com

# Test HTTPS connection
curl -I https://github.com
```

### Clear Git Credentials (if authentication issues)
```powershell
# Windows Credential Manager
# Remove GitHub credentials from Windows Credential Manager
# Control Panel > Credential Manager > Windows Credentials
```

### Use Git LFS for Large Files
If you need to push large model files:

```powershell
# Install Git LFS
# Download from: https://git-lfs.github.com/

# Initialize Git LFS
git lfs install

# Track large files
git lfs track "*.safetensors"
git lfs track "*.bin"

# Add and commit
git add .gitattributes
git commit -m "Add Git LFS tracking"
git push origin main --force
```

---

## 📋 Recommended Steps

1. **Check GitHub Status**: https://www.githubstatus.com
2. **Increase HTTP Buffer**:
   ```powershell
   git config http.postBuffer 524288000
   ```
3. **Try Push Again**:
   ```powershell
   git push origin main --force
   ```
4. **If Still Failing**: Use fresh repository script
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1
   ```

---

## 🎯 Most Likely Solution

For your case, since we've been working on large files, try:

```powershell
# 1. Increase HTTP buffer
git config http.postBuffer 524288000

# 2. Verify no large files
git status

# 3. Push with verbose output
git push origin main --force --verbose
```

If this doesn't work, the fresh repository script should solve it:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\fix_and_push_final.ps1
git push origin main --force
```

---

## 📞 GitHub Support

If none of these work:
1. Check GitHub status page
2. Wait 10-15 minutes and retry
3. Try from a different network
4. Contact GitHub support if issue persists

---

**Last Updated**: 2025-11-05

