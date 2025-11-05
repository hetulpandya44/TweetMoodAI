# Twitter App Configuration Guide

When creating or configuring your Twitter App, you'll be asked for certain URLs. Here's what to fill in for TweetMoodAI (API-only application):

## Required Fields for App Configuration

### 1. Callback URI / Redirect URL (required)

**For API-only applications (like TweetMoodAI):**

Since we're using Bearer Token authentication (not OAuth), you don't actually need a real callback URL. However, Twitter requires this field.

**Recommended Options:**

#### Option A: Localhost (Recommended)
```
http://localhost:8000/callback
```
or
```
http://127.0.0.1:8000/callback
```

#### Option B: Your Future Production URL
If you plan to deploy:
```
https://yourdomain.com/callback
```

#### Option C: Generic Placeholder
```
http://localhost
```

**Why this works:**
- We're using Bearer Token authentication, not OAuth
- The callback URL is only needed for OAuth user authentication flows
- Twitter requires the field, but won't actually use it for Bearer Token API calls

---

### 2. Website URL (required)

**Recommended Options:**

#### Option A: GitHub Repository (Recommended - If you have one)
```
https://github.com/yourusername/TweetMoodAI
```
If you don't have a GitHub repo, you can use:
```
https://github.com
```

#### Option B: Example.com (Always works)
```
http://example.com
```
or
```
https://example.com
```

#### Option C: Personal Website
```
https://yourwebsite.com
```

#### Option D: Twitter/X Profile (If you have one)
```
https://x.com/yourusername
```
or
```
https://twitter.com/yourusername
```

#### Option E: Try with different localhost format
```
http://127.0.0.1:8000
```

**Why this works:**
- Twitter requires this for app identification
- It's not actively used for Bearer Token authentication
- Can be updated later if needed

---

## Complete App Info Example

Here's what your App configuration might look like:

```
App Name: TweetMoodAI-App
App Environment: Development (or Production)

Callback URI / Redirect URL:
http://localhost:8000/callback

Website URL:
http://example.com
```
*Note: If localhost gives "invalid URL" error, use `http://example.com` for Website URL instead*

---

## Important Notes

### ✅ For Bearer Token API Access:
- These URLs are **not actively used** for Bearer Token authentication
- Bearer Token works independently of these URLs
- Twitter just requires them as part of app registration

### ⚠️ If You Plan to Use OAuth Later:
- You'll need to update the Callback URI to your actual endpoint
- The callback URL must match exactly what you use in your OAuth requests
- For now, localhost is fine for API-only access

### 🔄 You Can Update Later:
- These fields can be edited after app creation
- Go to App Settings → Edit App to change them

---

## Step-by-Step: Filling App Info

1. **App Name**: `TweetMoodAI-App` (or any name you prefer)

2. **Callback URI / Redirect URL**: 
   - Type: `http://localhost:8000/callback`
   - Click "Save" or "Add"

3. **Website URL**: 
   - Type: `http://localhost:8000`
   - Click "Save"

4. **Add another URI** (if needed):
   - Usually not required
   - Only add if Twitter specifically asks for multiple URIs

5. **Complete the setup** and proceed to generate your Bearer Token

---

## Verification

After setting up:

1. ✅ Your app should be created successfully
2. ✅ You can generate Bearer Token in "Keys and tokens" tab
3. ✅ These URLs won't affect your API calls using Bearer Token

---

## Troubleshooting

### Error: "Invalid URL format" or "Invalid URL"

**For Website URL specifically**, Twitter sometimes rejects localhost. Try these in order:

1. **First try - Example.com (most reliable)**:
   ```
   http://example.com
   ```

2. **GitHub**:
   ```
   https://github.com
   ```
   Or if you have a GitHub repo:
   ```
   https://github.com/yourusername/TweetMoodAI
   ```

3. **Your Twitter/X profile**:
   ```
   https://twitter.com/yourusername
   ```
   or
   ```
   https://x.com/yourusername
   ```

4. **Different localhost format**:
   ```
   http://127.0.0.1:8000
   ```

**For Callback URI**, these usually work:
- `http://localhost:8000/callback` (should work)
- `http://127.0.0.1:8000/callback`
- `http://localhost` (simplest)

### Error: "Callback URL not whitelisted"
- For Bearer Token API, this shouldn't be an issue
- If you see this, try `http://localhost` instead
- Or use `https://yourdomain.com/callback` if you have one

### Can't Save App Info
- Make sure you're using HTTP or HTTPS protocol
- Try `http://localhost` if having issues
- Clear browser cache and try again

---

## For Production (Future)

If you deploy your application:

1. **Update Callback URI** to your production URL:
   ```
   https://yourdomain.com/api/callback
   ```

2. **Update Website URL** to your actual website:
   ```
   https://yourdomain.com
   ```

3. **Add Multiple URIs** if needed (for different environments):
   - Development: `http://localhost:8000/callback`
   - Production: `https://yourdomain.com/callback`

---

**Remember**: For Bearer Token authentication (what we're using), these URLs are just placeholders. Your API will work fine with localhost URLs!

