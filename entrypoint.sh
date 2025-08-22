#!/usr/bin/env bash

set -euo pipefail

# Generate timestamp for filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_${TIMESTAMP}.sql"

# Create backup using mysqldump
mysqldump --host="$MYSQL_HOST" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --port="$MYSQL_PORT" "$MYSQL_DATABASE" > "$BACKUP_FILE"

# Configure rclone
rclone config touch
cat <<EOF > ~/.config/rclone/rclone.conf
[remote]
type = s3
provider = Cloudflare
access_key_id = $R2_ACCESS_KEY_ID
secret_access_key = $R2_SECRET_ACCESS_KEY
endpoint = $R2_ENDPOINT
acl = private
EOF

# Upload the backup file to R2
rclone copy "$BACKUP_FILE" remote:"$R2_BUCKET"/"$R2_PATH"