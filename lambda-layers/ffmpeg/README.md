# FFmpeg Lambda Layer

This directory contains the FFmpeg and FFprobe binaries for the Lambda layer.

## Setup Instructions

You need to download and place the FFmpeg binaries in the `bin/` directory before deploying.

### Option 1: Pre-compiled Static Binaries (Recommended)

Download from John Van Sickle's static builds:

```bash
# Download the latest static build
wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz

# Extract the archive
tar -xf ffmpeg-release-amd64-static.tar.xz

# Copy binaries to the layer directory
cp ffmpeg-*-amd64-static/ffmpeg bin/
cp ffmpeg-*-amd64-static/ffprobe bin/

# Verify binaries
ls -la bin/
```

### Option 2: FFBinaries

Download from FFBinaries project:

```bash
# Download ffmpeg and ffprobe
wget https://github.com/vot/ffbinaries-prebuilt/releases/download/v4.4.1/ffmpeg-4.4.1-linux-64.zip
wget https://github.com/vot/ffbinaries-prebuilt/releases/download/v4.4.1/ffprobe-4.4.1-linux-64.zip

# Extract to bin directory
unzip ffmpeg-4.4.1-linux-64.zip -d bin/
unzip ffprobe-4.4.1-linux-64.zip -d bin/

# Make executable
chmod +x bin/ffmpeg bin/ffprobe
```

### Option 3: Build from Source

If you need specific compilation options:

```bash
# This is more complex and requires a Linux environment
# Follow the official FFmpeg compilation guide
# https://trac.ffmpeg.org/wiki/CompilationGuide
```

## Requirements

- Binaries must be Linux x86_64 compatible
- Binaries should be statically linked (no external dependencies)
- Maximum layer size is 250MB (uncompressed)

## Structure

After setup, the directory should look like:

```
lambda-layers/ffmpeg/
├── bin/
│   ├── ffmpeg    # Main FFmpeg binary
│   └── ffprobe   # Metadata extraction tool
└── README.md     # This file
```

## Testing

Test the binaries locally (if on Linux):

```bash
# Test ffprobe
./bin/ffprobe -version

# Test ffmpeg
./bin/ffmpeg -version
```

## Notes

- The Lambda layer will make these binaries available at `/opt/bin/` in the Lambda runtime
- The Lambda function expects `ffprobe` at `/opt/bin/ffprobe`
- These binaries will be used for video metadata extraction
- Total layer size should be under 250MB uncompressed 