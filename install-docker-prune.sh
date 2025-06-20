#!/bin/bash

# ==============================================================================
#  สคริปต์สำหรับติดตั้งและตั้งค่าระบบ Docker Prune อัตโนมัติแบบ Aggressive
# ==============================================================================
#
#  สคริปต์นี้จะทำการ:
#  1. สร้างสคริปต์ docker_aggressive_prune.sh ใน /usr/local/bin/
#  2. สร้าง Cron job ใน /etc/cron.d/ เพื่อรันสคริปต์ทุกวันตอน 08:30 น.
#  3. สร้างไฟล์ตั้งค่า logrotate ใน /etc/logrotate.d/ เพื่อจัดการขนาดไฟล์ Log
#
#  วิธีใช้:
#  1. บันทึกสคริปต์นี้เป็นไฟล์ เช่น install_docker_prune.sh
#  2. รันด้วยคำสั่ง: sudo bash install_docker_prune.sh
#
# ==============================================================================

# หยุดการทำงานทันทีหากมีคำสั่งใดล้มเหลว
set -e

# --- ตรวจสอบว่ารันด้วยสิทธิ์ root หรือไม่ ---
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ กรุณารันสคริปต์นี้ด้วยสิทธิ์ root หรือใช้ sudo" >&2
  exit 1
fi

echo "🚀 เริ่มต้นการติดตั้งระบบ Docker Prune อัตโนมัติ..."
echo "----------------------------------------------------"

# --- ขั้นตอนที่ 1: สร้างสคริปต์ Prune ---
echo ">>> 1. กำลังสร้างสคริปต์ prune ใน /usr/local/bin/docker_aggressive_prune.sh..."

cat > /usr/local/bin/docker_aggressive_prune.sh << 'EOF'
#!/bin/bash
echo "========== Starting AGGRESSIVE Docker system prune at $(date) =========="
/usr/bin/docker system prune -a -f
echo "========== AGGRESSIVE Docker system prune finished at $(date) =========="
echo ""
EOF

chmod +x /usr/local/bin/docker_aggressive_prune.sh
echo "✅ สร้างสคริปต์ Prune สำเร็จ"
echo ""

# --- ขั้นตอนที่ 2: สร้าง Cron Job ---
# การสร้างไฟล์ใน /etc/cron.d/ เป็นวิธีที่แนะนำสำหรับ system-wide cron jobs
echo ">>> 2. กำลังสร้าง Cron job ใน /etc/cron.d/docker-prune..."

cat > /etc/cron.d/docker-prune << 'EOF'
# รันสคริปต์ล้าง Docker แบบ aggressive ทุกวัน เวลา 08:30 น.
30 8 * * * root /usr/local/bin/docker_aggressive_prune.sh >> /var/log/docker-prune.log 2>&1
EOF

# ตั้งค่า permission ที่ถูกต้องสำหรับ cron file
chmod 0644 /etc/cron.d/docker-prune

echo "✅ สร้าง Cron job สำเร็จ"
echo ""

# --- ขั้นตอนที่ 3: ตั้งค่า Logrotate ---
echo ">>> 3. กำลังตั้งค่า Logrotate ใน /etc/logrotate.d/docker-prune..."

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

echo "✅ ตั้งค่า Logrotate สำเร็จ"
echo ""

# --- สิ้นสุดการทำงาน ---
echo "----------------------------------------------------"
echo "🎉 การติดตั้งทั้งหมดเสร็จสมบูรณ์!"
echo "เซิร์ฟเวอร์ของคุณจะทำการล้าง Docker อัตโนมัติทุกวันตอน 08:30 น."
