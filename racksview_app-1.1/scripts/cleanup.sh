#!/bin/bash
set -e

# Parameters
TARGET_BASE="/opt/racksview/var/video"    # Base directory for recorded files
KEEP_REC_DAYS=90

# Remove old recordings
find "${TARGET_BASE}" -type f -mtime +${KEEP_REC_DAYS} -delete

# Remove empty directories
find "${TARGET_BASE}" -type d -empty -delete

/opt/racksview/scripts/stop_services.sh
/opt/racksview/scripts/start_services.sh
