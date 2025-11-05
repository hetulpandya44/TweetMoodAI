# Twitter API Free Tier Limitations

You're using Twitter's **Free Tier**, which has specific limitations you need to be aware of:

## Free Tier Limits

### Read Limits (What We Need)
- **100 Posts per month** (total)
- This means you can retrieve up to **100 tweets total per month**
- Not 100 per request, but **100 total across all requests**

### Write Limits
- **500 writes per month**
- Not relevant for tweet collection (we're only reading)

### Other Limits
- **1 App** allowed
- **1 Environment** allowed
- Access to **Twitter API v2** (limited endpoints)

---

## Impact on TweetMoodAI

### ⚠️ Important Considerations

1. **Monthly Quota**: You have **100 tweets per month total**
   - If you fetch 100 tweets today, you've used your entire monthly quota
   - The quota resets monthly (calendar month)

2. **Batch Size**: You can fetch up to 100 tweets per request
   - But your **total monthly limit is only 100 tweets**
   - So you can only make **1 request of 100 tweets** per month
   - Or make multiple smaller requests that add up to 100

3. **Testing**: Use small numbers for testing!
   - Test with `--max_tweets 5` or `--max_tweets 10`
   - Save your quota for actual data collection

---

## Recommendations

### For Development/Testing

```bash
# Test with very small numbers
python scripts/fetch_twitter_api.py --query "#test" --max_tweets 5
```

### For Actual Data Collection

```bash
# Use your full quota once per month
python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 100
```

**But remember**: After this, you've used all 100 tweets for the month!

---

## Script Behavior with Free Tier

Our script will:
- ✅ Fetch tweets successfully (up to 100 per month)
- ✅ Save to `data/tweets.json`
- ⚠️ You'll hit quota limit after 100 tweets total
- ⚠️ Will show rate limit errors if you exceed monthly quota

---

## Monitoring Your Usage

### Check Your Quota

1. Go to: https://developer.twitter.com/en/portal/dashboard
2. Click your **Project**
3. Look for **"Usage"** or **"Analytics"** section
4. See how many tweets you've used this month

### Twitter API Dashboard
- Shows remaining quota
- Resets monthly (usually on the 1st of each month)
- Track usage before making requests

---

## Best Practices for Free Tier

### 1. Plan Your Requests
- **Week 1**: Test with 5-10 tweets
- **Week 2-3**: Save quota
- **Week 4**: Use remaining quota for actual collection
- **Month End**: Full collection (up to 100 tweets)

### 2. Choose Queries Wisely
- Make each request count
- Use specific hashtags/queries that give relevant results
- Avoid making multiple test requests

### 3. Save Your Data
- Once you fetch tweets, save them locally
- Don't re-fetch the same data (wastes quota)
- Work with saved JSON files for analysis

### 4. Consider Upgrade (Future)
If you need more data:
- **Basic Tier**: More requests per month
- **Pro Tier**: Even higher limits
- Check Twitter Developer Portal for pricing

---

## Example Monthly Strategy

### Option A: Single Large Collection
```bash
# One time per month - collect 100 tweets
python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 100
```
**Result**: 100 tweets, used entire quota

### Option B: Multiple Small Collections
```bash
# Week 1: Test with 10 tweets
python scripts/fetch_twitter_api.py --query "#test" --max_tweets 10

# Week 2: Collect 30 tweets
python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 30

# Week 3: Collect 30 tweets
python scripts/fetch_twitter_api.py --query "#machinelearning" --max_tweets 30

# Week 4: Collect remaining 30 tweets
python scripts/fetch_twitter_api.py --query "#python" --max_tweets 30
```
**Result**: 100 tweets total, spread across month

---

## Error Messages You Might See

### "Rate limit exceeded (429)"
- You've hit your monthly quota
- Wait until next month (quota resets)

### "Forbidden (403)"
- Could be quota-related
- Check your usage in Developer Portal

### "Too Many Requests"
- You're making requests too quickly
- Free tier has strict rate limits
- Space out your requests

---

## Upgrading (If Needed)

If 100 tweets/month isn't enough:

1. **Check Twitter Developer Portal**:
   - Go to https://developer.twitter.com/en/portal/dashboard
   - Look for upgrade options
   - Compare tiers and pricing

2. **Consider Alternatives**:
   - Use saved data multiple times
   - Work with smaller datasets
   - Use other data sources to supplement

---

## Current Script Settings

Our `fetch_twitter_api.py` script:
- ✅ Works with Free Tier
- ✅ Respects rate limits
- ⚠️ Won't prevent you from using all 100 tweets
- 💡 Use `--max_tweets` parameter wisely!

---

## Quick Reference

| What | Free Tier Limit |
|------|----------------|
| Tweets per request | Up to 100 |
| **Tweets per month** | **100 total** |
| Requests per 15 min | 300 (but monthly quota limits you) |
| Apps | 1 |
| Environments | 1 |

---

**Remember**: With Free Tier, every tweet counts! Use your quota wisely. 🎯

