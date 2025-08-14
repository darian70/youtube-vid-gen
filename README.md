# Automated YouTube Video Generation System

A fully automated system that creates calming, sleep-friendly etymology videos and uploads them to YouTube using n8n workflows, Piper TTS, and Docker.

## Features

- **Daily Automated Videos**: Cron-triggered workflow that sources words from Urban Dictionary and Reddit, creates etymology videos, and uploads to YouTube
- **On-Demand Video Creation**: Webhook endpoint to create videos for specific words instantly
- **Professional Video Production**: Generates videos with soft backgrounds, subtitles, thumbnails, and calming narration
- **Zero Human Intervention**: Fully automated pipeline from word selection to YouTube upload

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed
- YouTube OAuth2 credentials (see Setup section)

### 2. Setup

```bash
# Clone/navigate to project directory
cd "Ai youtube vid gen"

# Download TTS voice models
./setup-voices.sh

# Start the system
docker-compose up -d
```

### 3. Configure YouTube OAuth2

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable YouTube Data API v3
4. Create OAuth2 credentials (Web application)
5. Add `http://localhost:5678/rest/oauth2-credential/callback` to authorized redirect URIs
6. Access n8n at http://localhost:5678 (admin/admin12345)
7. Go to Settings > Credentials > Add Credential > YouTube OAuth2 API
8. Enter your Client ID and Client Secret
9. Name it "YouTube OAuth2 API" (exact name required by workflows)

### 4. Import Workflows

1. Access n8n at http://localhost:5678
2. Import `workflows/daily.json` for automated daily videos
3. Import `workflows/on-demand.json` for webhook-triggered videos
4. Activate both workflows

## Usage

### Daily Automated Videos

The daily workflow automatically:
- Runs every day at 8:00 AM UTC
- Sources trending words from Urban Dictionary and Reddit
- Creates etymology videos with calming narration
- Uploads to YouTube as private videos (scheduled for next day)

### On-Demand Video Creation

Create videos for specific words via HTTP POST:

```bash
curl -X POST http://localhost:5678/webhook/create-video \
  -H "Content-Type: application/json" \
  -d '{"term": "serendipity"}'
```

Response:
```json
{
  "success": true,
  "videoId": "abc123xyz",
  "term": "serendipity",
  "runId": "2024-01-15T10-30-00-000Z"
}
```

## System Architecture

### Services

- **n8n**: Workflow orchestration platform
- **Piper TTS**: Text-to-speech service for narration
- **FFmpeg**: Video rendering and processing (built into n8n container)

### Workflow Components

1. **Word Sourcing**: Urban Dictionary API + Reddit API
2. **Etymology Research**: Wiktionary MediaWiki API
3. **Script Generation**: AI-optimized calm narration
4. **Audio Generation**: Piper TTS with high-quality voice
5. **Video Rendering**: FFmpeg with soft backgrounds and subtitles
6. **YouTube Upload**: OAuth2 authenticated upload with metadata

### File Structure

```
├── docker-compose.yml          # Docker services configuration
├── Dockerfile.n8n             # Custom n8n image with ffmpeg
├── workflows/
│   ├── daily.json             # Daily automated workflow
│   └── on-demand.json         # Webhook-triggered workflow
├── setup-voices.sh            # Voice model download script
├── n8n_data/                  # n8n persistent data
├── piper_data/                # TTS voice models
└── workspace/                 # Video output directory
```

## Configuration

### Environment Variables

Key settings in `docker-compose.yml`:

- `N8N_BASIC_AUTH_USER=admin`
- `N8N_BASIC_AUTH_PASSWORD=admin12345`
- `N8N_ENCRYPTION_KEY=JmJrOqvR9XQ2oY3c7Uq1t8mF5sP4wD2r`

### Voice Models

Default voice: `en_US-lessac-medium.onnx` (high quality, natural)
Backup voice: `en_US-amy-low.onnx` (faster processing)

To add more voices, download from [Piper Voices](https://huggingface.co/rhasspy/piper-voices) to `piper_data/`

### Video Settings

- Resolution: 1280x720 (HD)
- Background: Soft dark blue with subtle vignette
- Subtitles: Timed SRT with elegant styling
- Audio: AAC 128kbps, optimized for sleep content

## Monitoring & Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f n8n
docker-compose logs -f piper

# Check workflow execution in n8n UI
# Go to http://localhost:5678 > Executions
```

## Troubleshooting

### Common Issues

1. **Voice not found**: Run `./setup-voices.sh` to download models
2. **YouTube upload fails**: Check OAuth2 credentials in n8n
3. **FFmpeg errors**: Ensure fonts are installed (handled by Dockerfile)
4. **Webhook not responding**: Check workflow is active and n8n is running

### Reset System

```bash
# Stop and remove all data
docker-compose down -v
rm -rf n8n_data/ workspace/

# Restart fresh
docker-compose up -d
# Re-import workflows and configure credentials
```

## API Reference

### Webhook Endpoints

- `POST /webhook/create-video` - Create video for specific term
  - Body: `{"term": "word"}`
  - Response: `{"success": true, "videoId": "...", "term": "...", "runId": "..."}`

### n8n Management

- Web UI: http://localhost:5678
- Username: admin
- Password: admin12345

## Development

### Modifying Workflows

1. Edit workflows in n8n UI
2. Export updated JSON from n8n
3. Replace files in `workflows/` directory
4. Commit changes to version control

### Adding New Voice Models

1. Download `.onnx` and `.onnx.json` files to `piper_data/`
2. Update voice name in workflow "Init Context" nodes
3. Test with on-demand workflow first

### Customizing Video Style

Edit the "Render Video" node ffmpeg command to modify:
- Background colors and effects
- Text positioning and styling
- Subtitle appearance
- Video quality settings

## Security Notes

- Change default n8n credentials before production use
- Store YouTube OAuth2 credentials securely
- Use environment variables for sensitive data
- Consider using Docker secrets for production deployment

## License

This project is for educational and personal use. Ensure compliance with:
- YouTube Terms of Service
- Urban Dictionary API terms
- Reddit API terms
- Wiktionary content licenses

## Support

For issues and questions:
1. Check n8n execution logs in the web UI
2. Review Docker container logs
3. Verify all credentials are properly configured
4. Ensure all required services are running

The system is designed to run 24/7 with minimal intervention once properly configured.
