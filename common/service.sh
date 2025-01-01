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

su -lp 2000 -c "cmd notification post -S bigtext -t 'Qingque' 'Tag' 'Alright, no more teasing, okay?'"

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
setprop init.svc.vendor.semc.hardware.thermal-1-0 stopped
setprop init.svc.vendor.semc.hardware.thermal-1-1 stopped
setprop init.svc.vendor.thermal-hal-2-0.mtk stopped
setprop init.svc.thermal_core stopped
# Thermal Stop Semi-auto Methode
stop logd
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

# GPU Tweaks
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
echo "0" > /proc/sys/kernel/panic
echo "0" > /proc/sys/kernel/panic_on_oops
echo "0" > /proc/sys/kernel/panic_on_rcu_stall
echo "0" > /proc/sys/kernel/panic_on_warn
echo "0" > /sys/module/kernel/parameters/panic
echo "0" > /sys/module/kernel/parameters/panic_on_warn
echo "0" > /sys/module/kernel/parameters/panic_on_oops
echo "0" > /sys/vm/panic_on_oom

####################################
#Kernel Reclaim Threads
####################################
change_task_nice "kswapd" "-2"
change_task_nice "oom_reaper" "-2"
change_task_affinity "kswapd" "7f"
change_task_affinity "oom_reaper" "7f"

####################################
# Printk and Disable sysctl.conf (thx to KNTD-reborn)
####################################
if [ -e /system/etc/sysctl.conf ]; then
  mount -o remount,rw /system;
  mv /system/etc/sysctl.conf /system/etc/sysctl.conf.bak;
  mount -o remount,ro /system;
fi;
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "0" > /sys/kernel/printk_mode/printk_mode
echo "0" > /sys/module/printk/parameters/cpu
echo "0" > /sys/module/printk/parameters/pid
echo "0" > /sys/module/printk/parameters/printk_ratelimit
echo "0" > /sys/module/printk/parameters/time
echo "1" > /sys/module/printk/parameters/console_suspend
echo "1" > /sys/module/printk/parameters/ignore_loglevel
echo "off" > /proc/sys/kernel/printk_devkmsg

####################################
# I/O
####################################
for queue in /sys/block/*/queue; do
    echo "0" > "$queue/iostats"
done

####################################
# Surfaceflinger
####################################
setprop debug.sf.hw 1
setprop debug.sf.latch_unsignaled 1

#Release cache on boot (try cleaning)
echo "3" > /proc/sys/vm/drop_caches
echo "1" > /proc/sys/vm/compact_memory

####################################
# Wi-Fi Logs (thx to @LeanHijosdesusMadres)
####################################
rm -rf /data/vendor/wlan_logs
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs

#CAF Tweak
echo "0:1800000" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_freq
echo "230" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_ms

su -lp 2000 -c "cmd notification post -S bigtext -t 'Qingque' 'Tag' 'A free performance by Little Gui? There's no way I missing that.'"
