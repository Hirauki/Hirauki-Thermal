
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

list_thermal_services() {
	for rc in $(find /system/etc/init -type f && find /vendor/etc/init -type f && find /odm/etc/init -type f); do
		grep -r "^service" "$rc" | awk '{print $2}'
	done | grep thermal
}

for svc in $(list_thermal_services); do
	echo "Stopping $svc"
	start $svc
	stop $svc
done

for pid in $(pgrep thermal); do
	echo "Freeze $pid"
	kill -SIGSTOP $pid
done

for thermal in $(resetprop | awk -F '[][]' '/thermal/ {print $2}'); do
  if [[ $(resetprop "$thermal") == running ]] || [[ $(resetprop "$thermal") == restarting ]]; then
    stop "${thermal/init.svc.}"
    sleep 10
    resetprop -n "$thermal" stopped
  fi
done
for zone in /sys/class/thermal/thermal_zone*; do
	lock_val "disabled" $zone/mode
done
find /sys/devices/virtual/thermal -type f -exec chmod 000 {} + 2>/dev/null
echo "0" > /sys/kernel/msm_thermal/enabled
echo "N" > /sys/module/msm_thermal/parameters/enabled
echo "0" > /sys/module/msm_thermal/core_control/enabled
echo "0" > /sys/module/msm_thermal/vdd_restriction/enabled
echo "0" > /sys/devices/system/cpu/cpu_boost/sched_boost_on_input
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


echo "0" > /sys/class/kgsl/kgsl-3d0/bus_split
echo "0" > /sys/class/kgsl/kgsl-3d0/throttling
echo "1" > /sys/class/kgsl/kgsl-3d0/force_clk_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_bus_on
echo "1" > /sys/class/kgsl/kgsl-3d0/force_no_nap

lib_names="com.miHoYo. com.activision. com.garena. com.roblox. com.epicgames com.dts. UnityMain libunity.so libil2cpp.so libmain.so libcri_vip_unity.so libopus.so libxlua.so libUE4.so libAsphalt9.so libnative-lib.so libRiotGamesApi.so libResources.so libagame.so libapp.so libflutter.so libMSDKCore.so libFIFAMobileNeon.so libUnreal.so libEOSSDK.so libcocos2dcpp.so libgodot_android.so libgdx.so libgdx-box2d.so libminecraftpe.so libLive2DCubismCore.so libyuzu-android.so libryujinx.so libcitra-android.so libhdr_pro_engine.so libandroidx.graphics.path.so libeffect.so"

for path in /proc/sys/kernel/sched_lib_name /proc/sys/kernel/sched_lib_mask_force /proc/sys/walt/sched_lib_name /proc/sys/walt/sched_lib_mask_force; do
    if [ -w "$path" ]; then
        case "$path" in
            */sched_lib_name) echo "$lib_names" > "$path" ;;
            */sched_lib_mask_force) echo "255" > "$path" ;;
        esac
    fi
done

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

echo "0" > /sys/kernel/rcu_expedited
echo "0" > /sys/kernel/rcu_normal
echo "0" > /sys/devices/system/cpu/isolated
echo "0" > /proc/sys/kernel/sched_tunable_scaling
echo "1" > /proc/sys/kernel/timer_migration
echo "55" > /proc/sys/kernel/perf_cpu_time_max_percent
echo "1" > /proc/sys/kernel/sched_autogroup_enabled
echo "0" > /proc/sys/kernel/sched_child_runs_first
echo "10000000" > /proc/sys/kernel/sched_latency_ns 
echo "2000000" > /proc/sys/kernel/sched_wakeup_granularity_ns 
echo "3200000" > /proc/sys/kernel/sched_min_granularity_ns 
echo "2000000" > /proc/sys/kernel/sched_migration_cost_ns 
echo "32" > /proc/sys/kernel/sched_nr_migrate

for queue in /sys/block/*/queue/; do
    if [ -f "$queue/scheduler" ]; then
        sched=$(cat "$queue/scheduler")
        for algo in cfq noop kyber bfq mq-deadline none; do
            if echo "$sched" | grep -q "$algo"; then
                echo "$algo" > "$queue/scheduler"
                break
            fi
        done
        echo 0 > "$queue/add_random"
        echo 0 > "$queue/iostats"
        echo 64 > "$queue/read_ahead_kb"
        echo 512 > "$queue/nr_requests"
    fi
done

for dir in /sys/block/mmcblk0 /sys/block/mmcblk1 /sys/block/sd*; do
    if [ -d "$dir" ]; then
        [ ! -e "$dir/queue/iostats" ] || echo 0 > "$dir/queue/iostats"
        [ ! -e "$dir/queue/nr_requests" ] || echo 64 > "$dir/queue/nr_requests"
        [ ! -e "$dir/queue/add_random" ] || echo 0 > "$dir/queue/add_random"
        [ ! -e "$dir/queue/read_ahead_kb" ] || echo 32 > "$dir/queue/read_ahead_kb"
    fi
done

setprop debug.sf.hw 1
setprop debug.sf.latch_unsignaled 1

chmod 755 /sys/module/qti_haptics/parameters/vmax_mv_override
echo 500 > /sys/module/qti_haptics/parameters/vmax_mv_override
echo 0 > /sys/module/rmnet_data/parameters/rmnet_data_log_level

echo "3" > /proc/sys/vm/drop_caches
echo "1" > /proc/sys/vm/compact_memory
echo 0 > /d/tracing/tracing_on
echo 0 > /sys/kernel/debug/rpm_log

echo "0:1190000" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_freq
echo "120" > /sys/devices/system/cpu/cpu_boost/parameters/input_boost_ms
echo "0" > /sys/devices/system/cpu/cpu_boost/sched_boost_on_input

fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /preload
fstrim -v /product
fstrim -v /metadata
fstrim -v /odm
fstrim -v /data/dalvik-cache

su -lp 2000 -c "cmd notification post -S bigtext -t 'W' 'Tag' 'Wow, looks like those devices are heating up. Are you calling me out for this?'"
    exit 0
    
    
