#!/system/bin/sh
wait_until_login() {
  # In case of /data encryption is disabled
  while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
  sh /data/adb/modules/hirauki-thermal/system/etc/.nth_fc/.fc_main.sh
    sleep 3
  done
  # We don't have the permission to rw "/storage/emulated/0" before the user unlocks the screen
  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  true >"$test_file"
  while [[ ! -f "$test_file" ]]; do
    true >"$test_file"
    sleep 1
  done
  rm -f "$test_file"
}
wait_until_login

# Sleep some time to make sure init is completed
sleep 10

su -lp 2000 -c "cmd notification post -S bigtext -t 'Lucia Crimson' 'Tag' 'Maintain your pace and resilience against my moves.'"

####################################
# Tweaking Android (thx to Melody Script https://github.com/ionuttbara/melody_android)
####################################
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

####################################
# Services
####################################
su -c "stop logcat, logcatd, logd, tcpdump, cnss_diag, statsd, traced, idd-logreader, idd-logreadermain, stats dumpstate, aplogd, tcpdump, vendor.tcpdump, vendor_tcpdump, vendor.cnss_diag"

####################################
# Kill sensor
####################################
for thermal in $(resetprop | awk -F '[][]' '/thermal|init.svc.vendor.thermal-hal/ {print $2}'); do
  if [[ $(resetprop "$thermal") == "running" || $(resetprop "$thermal") == "restarting" ]]; then
    # Extract service name without the prefix
    service_name="${thermal/init.svc.vendor.thermal-hal/}"
    
    # Stop the corresponding service
    stop "${thermal/init.svc.}"
    sleep 10
    
  # Set the service property to "stopped"
    resetprop -n "$thermal" stopped
    echo "stopped" > "$service_name"
  fi
done
sleep 1
# Disable temp* thermal zone
for zone in /sys/class/thermal/thermal_zone*; do
    if [[ -d "$zone" ]]; then
        echo "Disabling temp in $zone"
        chmod a-r "$zone"/temp
    fi
done
  find /sys -name enabled | grep 'msm_thermal' | while IFS= read -r msm_thermal_status; do
    if [ "$(cat "$msm_thermal_status")" = 'Y' ]; then
      echo 'N' > "$msm_thermal_status"
    fi
    if [ "$(cat "$msm_thermal_status")" = '1' ]; then
      echo '0' > "$msm_thermal_status"
    fi
  done
  sleep 1
 find /sys -name mode | grep 'thermal_zone' | while IFS= read -r thermal_zone_status; do
  if [ "$(cat "$thermal_zone_status")" = 'enabled' ]; then
    echo 'disabled' > "$thermal_zone_status"
  fi
done
find /sys/devices/virtual/thermal -type f -exec chmod 000 {} +
sleep 1
# Thermal Stop Setprop Methode
setprop init.svc.android.thermal-hal stopped
# Thermal Stop Semi-auto Methode
sleep 10
stop logd
sleep 1
stop vendor.thermal-engine
sleep 1
stop vendor.thermal_manager
sleep 1
stop vendor.thermal-manager
sleep 1
stop vendor.thermal-hal-2-0
sleep 1
stop vendor.thermal-symlinks
sleep 1
stop thermal_mnt_hal_service
sleep 1
stop thermal
sleep 1
stop mi_thermald
sleep 1
stop thermald
sleep 1
stop thermalloadalgod
sleep 1
stop thermalservice
sleep 1
stop sec-thermal-1-0
sleep 1
stop debug_pid.sec-thermal-1-0
sleep 1
stop thermal-engine
sleep 1
stop vendor.semc.hardware.thermal-1-0
sleep 1
stop vendor.semc.hardware.thermal-1-1
sleep 1
stop vendor.thermal-hal-1-0
sleep 1
stop vendor-thermal-1-0
sleep 1
stop android.thermal-hal
sleep 1
stop vendor.thermal-hal-2-0.mtk
sleep 1
stop thermal-hal
sleep 1
stop thermal_core
sleep 1
stop android.thermal-hal
sleep 3
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
  # remove cache thermal
  rm -f /data/vendor/thermal/config
  rm -f /data/vendor/thermal/thermal.dump
  rm -f /data/vendor/thermal/last_thermal.dump
  rm -f /data/vendor/thermal/thermal_history.dump
    for therm_serv in $thermal_prop; do
        stop $therm_serv
    done
#improve
ext() {
    if [ -f "\$2" ]; then
        chmod 0666 "\$2"
        echo "\$1" > "\$2"
        chmod 0444 "\$2"
    fi
}
	
ext 6000000 /sys/class/power_supply/usb/current_max
ext 6100000 /sys/class/power_supply/usb/hw_current_max
ext 6100000 /sys/class/power_supply/usb/pd_current_max
ext 6100000 /sys/class/power_supply/usb/ctm_current_max
ext 6000000 /sys/class/power_supply/usb/sdp_current_max
ext 6000000 /sys/class/power_supply/main/current_max
ext 6100000 /sys/class/power_supply/main/constant_charge_current_max
ext 6000000 /sys/class/power_supply/battery/current_max
ext 6100000 /sys/class/power_supply/battery/constant_charge_current_max
ext 6500000 /sys/class/qcom-battery/restricted_current
ext 6000000 /sys/class/power_supply/pc_port/current_max
ext 6500000 /sys/class/power_supply/battery/constant_charge_current_max

# CPU Governor settings for LITTLE cores (cpu0-3) (thx to @Bias_khaliq)
  for cpu in /sys/devices/system/cpu/cpu[0-3]; do
    min_freq=$(cat $cpu/cpufreq/cpuinfo_min_freq)
    max_freq=$(cat $cpu/cpufreq/cpuinfo_max_freq)
    mid_freq=$(calculate_mid_freq $cpu)
     
     write $cpu/cpufreq/schedutil/hispeed_load "75"
     write $cpu/cpufreq/schedutil/iowait_boost_enable "0"
     write $cpu/cpufreq/schedutil/up_rate_limit_us "300"
     write $cpu/cpufreq/schedutil/down_rate_limit_us "2500"
     write $cpu/cpufreq/scaling_min_freq "$mid_freq"
     write $cpu/cpufreq/scaling_max_freq "$max_freq"
  done
  
# CPU Governor settings for big cores (cpu4-7) (thx to @Bias_khaliq)
  for cpu in /sys/devices/system/cpu/cpu[4-7]; do
    min_freq=$(cat $cpu/cpufreq/cpuinfo_min_freq)
    max_freq=$(cat $cpu/cpufreq/cpuinfo_max_freq)
    mid_freq=$(calculate_mid_freq $cpu)
  
     write $cpu/cpufreq/scaling_min_freq "$mid_freq"
     write $cpu/cpufreq/scaling_max_freq "$max_freq"
  done

# GPU Tweaks
echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 0 > /sys/class/kgsl/kgsl-3d0/throttling
echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split
echo 1 > /sys/class/kgsl/kgsl-3d0/force_no_nap
echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on

#unity
echo "com.miHoYo., com.activision., UnityMain, libunity.so, libil2cpp.so, libfb.so" > /proc/sys/kernel/sched_lib_name
echo "240" > /proc/sys/kernel/sched_lib_mask_force

#Deep Doze Enhancement (by @WeAreRavenS)
rm -f /storage/emulated/0/*.log;
settings delete global device_idle_constants
settings delete global device_idle_constants_user
dumpsys deviceidle enable light
dumpsys deviceidle enable deep
settings put global device_idle_constants
sleep 5

am kill logd
killall -9 logd
am kill logd.rc
killall -9 logd.rc

#Delete Logs
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

#fstrim
fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /preload
fstrim -v /product
fstrim -v /metadata
fstrim -v /odm
fstrim -v /data/dalvik-cache

####################################
# Kernel Debugging (thx to KTSR)
####################################
for i in "debug_mask" "log_level*" "debug_level*" "*debug_mode" "enable_ramdumps" "edac_mc_log*" "enable_event_log" "*log_level*" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enabled" "tracing_on" "mballoc_debug"; do
    for o in $(find /sys/ -type f -name "$i"); do
        echo "0" > "$o"
    done

echo "1" > /sys/module/spurious/parameters/noirqdebug
echo "0" > /sys/kernel/debug/sde_rotator0/evtlog/enable
echo "0" > /sys/kernel/debug/dri/0/debug/enable
echo "0" > /proc/sys/debug/exception-trace
echo "0" > /proc/sys/kernel/sched_schedstats

####################################
# Disable Kernel Panic
####################################
  write /proc/sys/kernel/panic "0"
  write /proc/sys/kernel/panic_on_oops "0"
  write /proc/sys/kernel/panic_on_warn "0"
  write /proc/sys/kernel/panic_on_rcu_stall "0"
  write /sys/module/kernel/parameters/panic "0"
  write /sys/module/kernel/parameters/panic_on_warn "0"
  write /sys/module/kernel/parameters/pause_on_oops "0"
  write /sys/module/kernel/panic_on_rcu_stall "0"

####################################
#Kernel Reclaim Threads
####################################
change_task_nice "kswapd" "-2"
change_task_nice "oom_reaper" "-2"
change_task_affinity "kswapd" "7f"
change_task_affinity "oom_reaper" "7f"

# Disable sysctl.conf to prevent ROM interference #1 
if [ -e /system/etc/sysctl.conf ]; then
  mount -o remount,rw /system;
  mv /system/etc/sysctl.conf /system/etc/sysctl.conf.bak;
  mount -o remount,rw /system;
fi;
done;

####################################
# Printk (thx to KNTD-reborn)
####################################
  write /proc/sys/kernel/printk "0 0 0 0"
  write /proc/sys/kernel/printk_devkmsg "off"
  write /sys/kernel/printk_mode/printk_mode "0"

# I/O
for queue in /sys/block/*/queue; do
    echo "0" > "$queue/iostats"
    echo "128" > "$queue/nr_requests"
done

####################################
# Surfaceflinger
####################################
setprop debug.sf.hw 1
setprop debug.sf.latch_unsignaled 1

####################################
#Parameter
####################################
chmod 755 /sys/module/qti_haptics/parameters/vmax_mv_override
echo 500 > /sys/module/qti_haptics/parameters/vmax_mv_override
echo 0 > /sys/module/rmnet_data/parameters/rmnet_data_log_level

#Release cache on boot (try cleaning)
echo "3" > /proc/sys/vm/drop_caches
echo "1" > /proc/sys/vm/compact_memory
echo 0 > /d/tracing/tracing_on
echo 0 > /sys/kernel/debug/rpm_log

#CAF Tweak
echo "0:1800000" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_freq
echo "230" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_ms

su -lp 2000 -c "cmd notification post -S bigtext -t 'Lucia Crimson' 'Tag' 'Amplify the power. Let's keep the momentum going.'"