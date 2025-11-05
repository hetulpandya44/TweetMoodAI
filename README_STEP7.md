# Step 7: Quick Reference

## 🚀 When Network is Fixed - Run This:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\docker_complete_setup.ps1
```

This single command will:
1. ✅ Build all Docker images
2. ✅ Start all services  
3. ✅ Test everything
4. ✅ Show you access URLs

---

## 🔧 To Fix Network Issue:

1. Open **Docker Desktop**
2. **Settings** → **Docker Engine**
3. Add DNS:
```json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```
4. Click **"Apply & Restart"**
5. Wait 60 seconds
6. Run the setup script above

---

## 📁 Key Files

- `docker-compose.yml` - Main orchestration
- `Dockerfile.backend` - Backend image
- `Dockerfile.frontend` - Frontend image
- `scripts/docker_complete_setup.ps1` - **Run this!**

---

## 📚 Full Documentation

See `STEP7_FINAL_SUMMARY.md` for complete details.

---

**Everything is ready. Just fix network DNS and run the setup script!** ✅

