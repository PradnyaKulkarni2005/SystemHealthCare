#!/bin/bash
# Log file where results will be saved
LOGFILE="system_health.log"

# Current timestamp (date + time)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
# check_disk- Check root (/) partition disk usage

check_disk() {
    # Get the usage percentage of root filesystem 
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    # If usage > 80% → log a warning, otherwise log OK
    if [ "$USAGE" -gt 80 ]; then
        echo "[$TIMESTAMP] Disk Usage: $USAGE% (Warning: High usage)" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] Disk Usage: $USAGE% (OK)" | tee -a $LOGFILE
    fi
}
# check memory

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

# check cpu load 1 min avg
check_cpu() {
    # uptime → shows system load averages
    # awk → extracts the load average numbers
    # cut → takes the first number (1-min load average)
    # xargs → trims spaces
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)

    # Strip decimal part to compare as integer 
    LOAD_INT=${LOAD%.*}

    # If CPU load > 2 → warning, else OK
    if [ "$LOAD_INT" -gt 2 ]; then
        echo "[$TIMESTAMP] CPU Load: $LOAD (Warning: High load)" | tee -a $LOGFILE
    else
        echo "[$TIMESTAMP] CPU Load: $LOAD (OK)" | tee -a $LOGFILE
    fi
}


# Check if a system service is running

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


check_disk          
check_memory        
check_cpu           
check_service sshd  
