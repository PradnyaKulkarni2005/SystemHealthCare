#!/bin/bash
# ==========================================
# System Health Monitoring Script
# Author: Your Name
# Date: 2025-09-14
# Description:
#   This script checks:
#     - Disk usage
#     - Memory usage
#     - CPU load
#     - Status of important services (e.g., sshd)
#   Results are logged into system_health.log with timestamps.
# ==========================================

# Log file where results will be saved
LOGFILE="system_health.log"

# Current timestamp (date + time)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# -------------------------------
# Function: check_disk
# Purpose: Check root (/) partition disk usage
# -------------------------------
check_disk() {
    # Get the usage percentage of root filesystem (e.g., 75)
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    # If usage > 80% → log a warning, otherwise log OK
    if [ "$USAGE" -gt 80 ]; then
        echo "[$TIMESTAMP] Disk Usage: $USAGE% (Warning: High usage)" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] Disk Usage: $USAGE% (OK)" | tee -a $LOGFILE
    fi
}

# -------------------------------
# Function: check_memory
# Purpose: Check memory (RAM) usage
# -------------------------------
check_memory() {
    # free → shows memory usage
    # awk → calculates used/total * 100 and rounds to whole number
    USAGE=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')

    # If memory > 80% → warning, else OK
    if [ "$USAGE" -gt 80 ]; then
        echo "[$TIMESTAMP] Memory Usage: $USAGE% (Warning: High usage)" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] Memory Usage: $USAGE% (OK)" | tee -a $LOGFILE
    fi
}

# -------------------------------
# Function: check_cpu
# Purpose: Check CPU load (1-minute average)
# -------------------------------
check_cpu() {
    # uptime → shows system load averages
    # awk → extracts the load average numbers
    # cut → takes the first number (1-min load average)
    # xargs → trims spaces
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)

    # Strip decimal part to compare as integer (e.g., 2.35 → 2)
    LOAD_INT=${LOAD%.*}

    # If CPU load > 2 → warning, else OK
    if [ "$LOAD_INT" -gt 2 ]; then
        echo "[$TIMESTAMP] CPU Load: $LOAD (Warning: High load)" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] CPU Load: $LOAD (OK)" | tee -a $LOGFILE
    fi
}

# -------------------------------
# Function: check_service
# Purpose: Check if a system service is running
# -------------------------------
check_service() {
    # $1 → first argument passed to the function (service name)
    SERVICE=$1

    # systemctl is-active --quiet → returns 0 if service is running
    if systemctl is-active --quiet $SERVICE; then
        echo "[$TIMESTAMP] Service $SERVICE: Active" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] Service $SERVICE: Inactive" | tee -a $LOGFILE
    fi
}

# -------------------------------
# Main script execution
# -------------------------------

# Run all checks one by one
check_disk          # Check disk space
check_memory        # Check RAM usage
check_cpu           # Check CPU load
check_service sshd  # Check SSH service (important for EC2 access)
