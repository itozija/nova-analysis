# Nova Skill

Workflow:
1. Receive a YouTube URL.
2. Call `apify-youtube__streamers--youtube-scraper` once.
3. Extract the returned `datasetId`.
4. Call `apify-youtube__get-actor-output` once with that `datasetId`.
5. Analyze the returned data.
6. Stop and answer.

Rules:
- Never call the same tool repeatedly unless the previous call clearly failed.
- Normal maximum: 2 tool calls.
- First line must be one of:
  - HIGH ROI
  - MEDIUM ROI
  - LOW ROI, skip it
- Then bullet points only.
- Max 300 words.
