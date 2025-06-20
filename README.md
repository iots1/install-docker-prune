# install-docker-prune

A simple shell script to install Docker and automatically set up a scheduled Docker system prune to clean up unused data.

## 🚀 Features

- 📦 Installs the latest version of Docker
- 🧹 Sets up a cron job to run `docker system prune` regularly
- 🕒 Helps save disk space by removing unused containers, networks, images, and build cache

## 📂 Files

- `install.sh`: Main script to install Docker and configure cron
- `docker-prune.sh`: Script that runs `docker system prune -af`
- `crontab.txt`: Cron schedule (default: once daily at midnight)

## 🛠️ Requirements

- Ubuntu/Debian-based system (tested on Ubuntu 20.04+)
- sudo/root access

## 📦 Installation

### 1. Clone this repository

```bash
git clone https://github.com/iots1/install-docker-prune.git
cd install-docker-prune
```

### 2. Run the installation script

```bash
chmod +x install.sh
./install.sh
```

This script will:
- Install Docker if it’s not already installed
- Set the `docker-prune.sh` script to run daily using cron

## 📅 Cron Schedule

By default, the cron job runs daily at midnight:
```
0 0 * * * /usr/local/bin/docker-prune.sh >> /var/log/docker-prune.log 2>&1
```

You can edit the cron schedule by modifying `crontab.txt` before running `install.sh`.

## 🔒 Notes

- `docker system prune -af` will **remove all stopped containers, unused networks, dangling images, and build cache**. Use with care.
- Make sure your active containers and data volumes are not affected.

## 🧪 Test

You can run the prune script manually to test:

```bash
sudo ./docker-prune.sh
```

## 📝 License

MIT License

---

Created by [@iots1](https://github.com/iots1)
