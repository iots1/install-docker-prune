#!/bin/bash

# ==============================================================================
#  Installer script for the Aggressive Automatic Docker Prune system
# ==============================================================================
#
#  Version: Specifies Timezone directly in the Cron Job (CRON_TZ=Asia/Bangkok)
#
#  This script will:
#  1. Create the docker_aggressive_prune.sh script in /usr/local/bin/
#  2. Create a Cron job that uses CRON_TZ=Asia/Bangkok to run at 08:30
#  3. Create a logrotate configuration file in /etc/logrotate.d/
#
#  How to use:
#  1. Save this script to a file, e.g., install_docker_prune.sh
#  2. Run it with the command: sudo bash install_docker_prune.sh
#
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Check if running as root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ This script must be run as root or with sudo." >&2
  exit 1
fi

echo "🚀 Starting the Docker Prune system installation (with specified Timezone)..."
echo "----------------------------------------------------"

# --- Step 1: Create the Prune Script ---
echo ">>> 1. Creating the prune script..."

cat > /usr/local/bin/docker_aggressive_prune.sh << 'EOF'
#!/bin/bash
echo "========== Starting AGGRESSIVE Docker system prune at $(date) =========="
/usr/bin/docker system prune -a -f
echo "========== AGGRESSIVE Docker system prune finished at $(date) =========="
echo ""
EOF

chmod +x /usr/local/bin/docker_aggressive_prune.sh
echo "✅ Prune script created successfully."
echo ""

# --- Step 2: Create the Cron Job ---
echo ">>> 2. Creating Cron job with Timezone set to Asia/Bangkok..."

cat > /etc/cron.d/docker-prune << 'EOF'
# Set the timezone specifically for this cron job.
CRON_TZ=Asia/Bangkok

# Run the aggressive Docker prune script every day at 08:30 (Asia/Bangkok time).
30 8 * * * root /usr/local/bin/docker_aggressive_prune.sh >> /var/log/docker-prune.log 2>&1
EOF

# Set the correct permissions for the cron file
chmod 0644 /etc/cron.d/docker-prune

echo "✅ Cron job created successfully."
echo ""

# --- Step 3: Set up Logrotate ---
echo ">>> 3. Setting up Logrotate..."

cat > /etc/logrotate.d/docker-prune << 'EOF'
/var/log/docker-prune.log {
    size 5M
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

echo "✅ Logrotate setup complete."
echo ""

# --- End of script ---
echo "----------------------------------------------------"
echo "🎉 Installation complete!"
echo "Your server will now perform an automatic Docker prune at 08:30 (Thai time), regardless of the system's timezone."
