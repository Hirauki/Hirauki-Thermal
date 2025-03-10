#!/system/bin/sh
wait_until_login() {
  while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
  sh /data/adb/modules/hirauki-thermal/system/etc/.nth_fc/.fc_main.sh
    sleep 3
  done
  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  true >"$test_file"
  while [[ ! -f "$test_file" ]]; do
    true >"$test_file"
    sleep 1
  done
  rm -f "$test_file"
}

su -lp 2000 -c "cmd notification post -S bigtext -t 'W' 'Tag' 'Unfortunately, the performance has dropped significantly today.'"

cmd settings put global activity_starts_logging_enabled 0
cmd settings put global ble_scan_always_enabled 0
cmd settings put global hotword_detection_enabled 0
cmd settings put global mobile_data_always_on 0
cmd settings put global network_recommendations_enabled 0
cmd settings put global wifi_scan_always_enabled 0
cmd settings put secure adaptive_sleep 0
cmd settings put secure screensaver_activate_on_dock 0  
cmd settings put secure screensaver_activate_on_sleep 0
cmd settings put secure screensaver_enabled 0
cmd settings put secure send_action_app_error 0
cmd settings put system air_motion_engine 0
cmd settings put system air_motion_wake_up 0
cmd settings put system intelligent_sleep_mode 0
cmd settings put system master_motion 0
cmd settings put system motion_engine 0
cmd settings put system nearby_scanning_enabled 0
cmd settings put system nearby_scanning_permission_allowed 0
cmd settings put system rakuten_denwa 0
cmd settings put system send_security_reports 0

for thermal in $(resetprop | awk -F '[][]' '/thermal/ {print $2}'); do
  if [[ $(resetprop "$thermal") == running ]] || [[ $(resetprop "$thermal") == stopped ]]; then
    stop "${thermal/init.svc.}"
    sleep 10
    resetprop -n "$thermal" stopped
  fi
done
find /sys/devices/virtual/thermal -type f -exec chmod 000 {} +
sleep 1
# Disable Via Props
  if resetprop dalvik.vm.dexopt.thermal-cutoff | grep -q '2'; then
    resetprop -n dalvik.vm.dexopt.thermal-cutoff 0
  fi
  if resetprop sys.thermal.enable | grep -q 'true'; then
    resetprop -n sys.thermal.enable false
  fi
  if resetprop ro.thermal_warmreset | grep -q 'true'; then
    resetprop -n ro.thermal_warmreset false
  fi
sleep 1    
# Universal Thermal Disabler
echo 0 > /sys/class/thermal/thermal_zone*/mode
sleep 1
  if resetprop dalvik.vm.dexopt.thermal-cutoff | grep -q '2'; then
    resetprop -n dalvik.vm.dexopt.thermal-cutoff 0
  fi
  if resetprop sys.thermal.enable | grep -q 'true'; then
    resetprop -n sys.thermal.enable false
  fi
  if resetprop ro.thermal_warmreset | grep -q 'true'; then
    resetprop -n ro.thermal_warmreset false
  fi
sleep 1
  rm -f /data/vendor/thermal/config
  rm -f /data/vendor/thermal/thermal.dump
  rm -f /data/vendor/thermal/last_thermal.dump
  rm -f /data/vendor/thermal/thermal_history.dump
    for therm_serv in $thermal_prop; do
        stop $therm_serv
    done
ext() {
    if [ -f "\$2" ]; then
        chmod 0666 "\$2"
        echo "\$1" > "\$2"
        chmod 0444 "\$2"
    fi
}
	
ext 5000000 /sys/class/power_supply/usb/current_max
ext 5100000 /sys/class/power_supply/usb/hw_current_max
ext 5100000 /sys/class/power_supply/usb/pd_current_max
ext 5100000 /sys/class/power_supply/usb/ctm_current_max
ext 5000000 /sys/class/power_supply/usb/sdp_current_max
ext 5000000 /sys/class/power_supply/main/current_max
ext 5100000 /sys/class/power_supply/main/constant_charge_current_max
ext 5000000 /sys/class/power_supply/battery/current_max
ext 5100000 /sys/class/power_supply/battery/constant_charge_current_max
ext 5500000 /sys/class/qcom-battery/restricted_current
ext 5000000 /sys/class/power_supply/pc_port/current_max
ext 5500000 /sys/class/power_supply/battery/constant_charge_current_max

if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/governor ]; then
  echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
fi

find /sys/devices/system/cpu -maxdepth 1 -name 'cpu?' | while IFS= read -r cpu; do
  echo performance > "$cpu/cpufreq/scaling_governor"
done
sleep 10
echo 0 > /sys/class/kgsl/kgsl-3d0/throttling
echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split
echo 1 > /sys/class/kgsl/kgsl-3d0/force_no_nap
echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on
#write /proc/sys/kernel/sched_lib_name "com.miHoYo., com.activision., UnityMain, libunity.so, libil2cpp.so"
echo "com.miHoYo., com.activision., UnityMain, libunity.so, libil2cpp.so, libfb.so" > /proc/sys/kernel/sched_lib_name
#write /proc/sys/kernel/sched_lib_mask_force 255
echo "240" > /proc/sys/kernel/sched_lib_mask_force

rm -f /storage/emulated/0/*.log;
settings delete global device_idle_constants
settings delete global device_idle_constants_user
dumpsys deviceidle enable light
dumpsys deviceidle enable deep
settings put global device_idle_constants
sleep 5

rm -rf /data/media/0/MIUI/Gallery
rm -rf /data/media/0/MIUI/.debug_log
rm -rf /data/media/0/MIUI/BugReportCache
rm -rf /data/media/0/mtklog
rm -rf /data/anr/*
rm -rf /dev/log/*
rm -rf /data/tombstones/*
rm -rf /data/log_other_mode/*
rm -rf /data/system/dropbox/*
rm -rf /data/system/usagestats/*
rm -rf /data/log/*
rm -rf /sys/kernel/debug/*

rm -rf /data/vendor/wlan_logs
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs

echo "0 0 0 0" > "/proc/sys/kernel/printk"
echo "0" > "/sys/kernel/printk_mode/printk_mode"
echo "0" > "/sys/module/printk/parameters/cpu"
echo "0" > "/sys/module/printk/parameters/pid"
echo "0" > "/sys/module/printk/parameters/printk_ratelimit"
echo "0" > "/sys/module/printk/parameters/time"
echo "1" > "/sys/module/printk/parameters/console_suspend"
echo "1" > "/sys/module/printk/parameters/ignore_loglevel"
echo "off" > "/proc/sys/kernel/printk_devkmsg"
echo "0" > /proc/sys/kernel/hung_task_timeout_secs
echo "0" > "/proc/sys/vm/panic_on_oom"
echo "0" > "/proc/sys/kernel/panic_on_oops"
echo "0" > "/proc/sys/kernel/panic"
echo "0" > "/proc/sys/kernel/softlockup_panic"

	for dir in /sys/block/mmcblk0 /sys/block/mmcblk1 /sys/block/sd*; do
		# Reduce heuristic read-ahead in exchange for I/O latency
		apply 32 "$dir/queue/read_ahead_kb"
	done

for dir in /sys/block/mmcblk0 /sys/block/mmcblk1 /sys/block/sd*; do
    if [ -d "$dir" ]; then
        [ ! -e "$dir/queue/iostats" ] || echo 0 > "$dir/queue/iostats"
        [ ! -e "$dir/queue/nr_requests" ] || echo 64 > "$dir/queue/nr_requests"
        [ ! -e "$dir/queue/add_random" ] || echo 0 > "$dir/queue/add_random"
        [ ! -e "$dir/queue/read_ahead_kb" ] || echo 32 > "$dir/queue/read_ahead_kb"
    fi
done

####################################
# Surfaceflinger
####################################
setprop debug.sf.hw 1
setprop debug.sf.latch_unsignaled 1

####################################
#Decrease Render treat speed
####################################
change_task_cgroup "surfaceflinger" "top-app" "cpuset"
change_task_cgroup "surfaceflinger" "foreground" "stune"
change_task_cgroup "android.hardware.graphics.composer" "top-app" "cpuset"
change_task_cgroup "android.hardware.graphics.composer" "foreground" "stune"
change_task_nice "surfaceflinger" "-20"
change_task_nice "android.hardware.graphics.composer" "-20"
change_task_affinity ".hardware." "0f"
change_task_affinity ".hardware.biometrics.fingerprint" "ff"
change_task_affinity ".hardware.camera.provider" "ff"
change_task_nice "system_server" "-18"
change_task_nice "com.android.systemui" "-18"

fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /preload
fstrim -v /product
fstrim -v /metadata
fstrim -v /odm
fstrim -v /data/dalvik-cache

echo "3" > /proc/sys/vm/drop_caches
echo "1" > /proc/sys/vm/compact_memory
echo 0 > /d/tracing/tracing_on
echo 0 > /sys/kernel/debug/rpm_log

echo "0:1800000" >/sys/devices/system/cpu/cpu_boost/parameters/input_boost_freq
echo "230" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_ms

su -lp 2000 -c "cmd notification post -S bigtext -t 'W' 'Tag' 'Wow, looks like those devices are heating up. Are you calling me out for this?'"
    exit 0
    
    
