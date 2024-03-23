defmodule ExtFit.Profile.Messages do
  use ExtFit.Profile, :messages
  @version "21.126.00"
  @moduledoc "FIT Messages for profile from version: #{@version}"
  message(:file_id) do
    field(0, :type, :file, example: "1")
    field(1, :manufacturer, :manufacturer, example: "1")

    field(2, :product, :uint16,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :garmin_product,
          ref_fields: [
            manufacturer: "garmin",
            manufacturer: "dynastream",
            manufacturer: "dynastream_oem",
            manufacturer: "tacx"
          ],
          type: :garmin_product
        },
        %{name: :favero_product, ref_fields: [manufacturer: "favero_electronics"], type: :favero_product}
      ]
    )

    field(3, :serial_number, :uint32z, example: "1")

    field(4, :time_created, :date_time,
      comment: "Only set for files that are can be created/erased.",
      example: "1"
    )

    field(5, :number, :uint16,
      comment: "Only set for files that are not created/erased.",
      example: "1"
    )

    field(8, :product_name, :string,
      comment: "Optional free form string to indicate the devices name or model",
      example: "20"
    )
  end

  message(:file_creator) do
    field(0, :software_version, :uint16, example: "1")
    field(1, :hardware_version, :uint8, example: "1")
  end

  message(:timestamp_correlation) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of UTC timestamp at the time the system timestamp was recorded.",
      units: ["s"]
    )

    field(0, :fractional_timestamp, :uint16,
      comment: "Fractional part of the UTC timestamp at the time the system timestamp was recorded.",
      scale: [32768],
      units: ["s"]
    )

    field(1, :system_timestamp, :date_time,
      comment: "Whole second part of the system timestamp",
      units: ["s"]
    )

    field(2, :fractional_system_timestamp, :uint16,
      comment: "Fractional part of the system timestamp",
      scale: [32768],
      units: ["s"]
    )

    field(3, :local_timestamp, :local_date_time,
      comment: "timestamp epoch expressed in local time used to convert timestamps to local time",
      units: ["s"]
    )

    field(4, :timestamp_ms, :uint16,
      comment: "Millisecond part of the UTC timestamp at the time the system timestamp was recorded.",
      units: ["ms"]
    )

    field(5, :system_timestamp_ms, :uint16,
      comment: "Millisecond part of the system timestamp",
      units: ["ms"]
    )
  end

  message(:software) do
    field(254, :message_index, :message_index, example: "1")
    field(3, :version, :uint16, example: "1", scale: ~c"d")
    field(5, :part_number, :string, example: "16")
  end

  message(:slave_device) do
    field(0, :manufacturer, :manufacturer, example: "1")

    field(1, :product, :uint16,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :garmin_product,
          ref_fields: [
            manufacturer: "garmin",
            manufacturer: "dynastream",
            manufacturer: "dynastream_oem",
            manufacturer: "tacx"
          ],
          type: :garmin_product
        },
        %{name: :favero_product, ref_fields: [manufacturer: "favero_electronics"], type: :favero_product}
      ]
    )
  end

  message(:capabilities) do
    field(0, :languages, :uint8z,
      array: true,
      comment: "Use language_bits_x types where x is index of array.",
      example: "4"
    )

    field(1, :sports, :sport_bits_0,
      array: true,
      comment: "Use sport_bits_x types where x is index of array.",
      example: "1"
    )

    field(21, :workouts_supported, :workout_capabilities, example: "1")
    field(23, :connectivity_supported, :connectivity_capabilities, example: "1")
  end

  message(:file_capabilities) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :type, :file, example: "1")
    field(1, :flags, :file_flags, example: "1")
    field(2, :directory, :string, example: "16")
    field(3, :max_count, :uint16, example: "1")
    field(4, :max_size, :uint32, example: "1", units: ["bytes"])
  end

  message(:mesg_capabilities) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :file, :file, example: "1")
    field(1, :mesg_num, :mesg_num, example: "1")
    field(2, :count_type, :mesg_count, example: "1")

    field(3, :count, :uint16,
      example: "1",
      subfields: [
        %{example: "1", name: :max_per_file_type, ref_fields: [count_type: "max_per_file_type"], type: :uint16},
        %{example: "1", name: :max_per_file, ref_fields: [count_type: "max_per_file"], type: :uint16},
        %{example: "1", name: :num_per_file, ref_fields: [count_type: "num_per_file"], type: :uint16}
      ]
    )
  end

  message(:field_capabilities) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :file, :file, example: "1")
    field(1, :mesg_num, :mesg_num, example: "1")
    field(2, :field_num, :uint8, example: "1")
    field(3, :count, :uint16, example: "1")
  end

  message(:device_settings) do
    field(0, :active_time_zone, :uint8, comment: "Index into time zone arrays.", example: "1")

    field(1, :utc_offset, :uint32,
      comment: "Offset from system time. Required to convert timestamp from system time to UTC.",
      example: "1"
    )

    field(2, :time_offset, :uint32,
      array: true,
      comment: "Offset from system time.",
      example: "2",
      units: ["s"]
    )

    field(4, :time_mode, :time_mode,
      array: true,
      comment: "Display mode for the time",
      example: "2"
    )

    field(5, :time_zone_offset, :sint8,
      array: true,
      comment: "timezone offset in 1/4 hour increments",
      example: "2",
      scale: [4],
      units: ["hr"]
    )

    field(12, :backlight_mode, :backlight_mode, comment: "Mode for backlight", example: "1")

    field(36, :activity_tracker_enabled, :bool,
      comment: "Enabled state of the activity tracker functionality",
      example: "1"
    )

    field(39, :clock_time, :date_time,
      comment: "UTC timestamp used to set the devices clock and date",
      example: "1"
    )

    field(40, :pages_enabled, :uint16,
      array: true,
      comment: "Bitfield to configure enabled screens for each supported loop",
      example: "1"
    )

    field(46, :move_alert_enabled, :bool,
      comment: "Enabled state of the move alert",
      example: "1"
    )

    field(47, :date_mode, :date_mode, comment: "Display mode for the date", example: "1")
    field(55, :display_orientation, :display_orientation, example: "1")
    field(56, :mounting_side, :side, example: "1")

    field(57, :default_page, :uint16,
      array: true,
      comment: "Bitfield to indicate one page as default for each supported loop",
      example: "1"
    )

    field(58, :autosync_min_steps, :uint16,
      comment: "Minimum steps before an autosync can occur",
      example: "1",
      units: ["steps"]
    )

    field(59, :autosync_min_time, :uint16,
      comment: "Minimum minutes before an autosync can occur",
      example: "1",
      units: ["minutes"]
    )

    field(80, :lactate_threshold_autodetect_enabled, :bool,
      comment: "Enable auto-detect setting for the lactate threshold feature."
    )

    field(86, :ble_auto_upload_enabled, :bool, comment: "Automatically upload using BLE")

    field(89, :auto_sync_frequency, :auto_sync_frequency, comment: "Helps to conserve battery by changing modes")

    field(90, :auto_activity_detect, :auto_activity_detect,
      comment: "Allows setting specific activities auto-activity detect enabled/disabled settings"
    )

    field(94, :number_of_screens, :uint8, comment: "Number of screens configured to display")

    field(95, :smart_notification_display_orientation, :display_orientation,
      comment: "Smart Notification display orientation"
    )

    field(134, :tap_interface, :switch)

    field(174, :tap_sensitivity, :tap_sensitivity,
      comment: "Used to hold the tap threshold setting",
      example: "1"
    )
  end

  message(:user_profile) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :friendly_name, :string, comment: "Used for Morning Report greeting", example: "16")
    field(1, :gender, :gender, example: "1")
    field(2, :age, :uint8, example: "1", units: ["years"])
    field(3, :height, :uint8, example: "1", scale: ~c"d", units: ["m"])
    field(4, :weight, :uint16, example: "1", scale: ~c"\n", units: ["kg"])
    field(5, :language, :language, example: "1")
    field(6, :elev_setting, :display_measure, example: "1")
    field(7, :weight_setting, :display_measure, example: "1")
    field(8, :resting_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(9, :default_max_running_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(10, :default_max_biking_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(11, :default_max_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(12, :hr_setting, :display_heart, example: "1")
    field(13, :speed_setting, :display_measure, example: "1")
    field(14, :dist_setting, :display_measure, example: "1")
    field(16, :power_setting, :display_power, example: "1")
    field(17, :activity_class, :activity_class, example: "1")
    field(18, :position_setting, :display_position, example: "1")
    field(21, :temperature_setting, :display_measure, example: "1")
    field(22, :local_id, :user_local_id, example: "1")
    field(23, :global_id, :byte, array: 6, example: "1")
    field(28, :wake_time, :localtime_into_day, comment: "Typical wake time")
    field(29, :sleep_time, :localtime_into_day, comment: "Typical bed time")
    field(30, :height_setting, :display_measure, example: "1")

    field(31, :user_running_step_length, :uint16,
      comment: "User defined running step length set to 0 for auto length",
      example: "1",
      scale: [1000],
      units: ["m"]
    )

    field(32, :user_walking_step_length, :uint16,
      comment: "User defined walking step length set to 0 for auto length",
      example: "1",
      scale: [1000],
      units: ["m"]
    )

    field(47, :depth_setting, :display_measure)
    field(49, :dive_count, :uint32)
  end

  message(:hrm_profile) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :enabled, :bool, example: "1")
    field(1, :hrm_ant_id, :uint16z, example: "1")
    field(2, :log_hrv, :bool, example: "1")
    field(3, :hrm_ant_id_trans_type, :uint8z, example: "1")
  end

  message(:sdm_profile) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :enabled, :bool, example: "1")
    field(1, :sdm_ant_id, :uint16z, example: "1")
    field(2, :sdm_cal_factor, :uint16, example: "1", scale: ~c"\n", units: ["%"])
    field(3, :odometer, :uint32, example: "1", scale: ~c"d", units: ["m"])

    field(4, :speed_source, :bool,
      comment: "Use footpod for speed source instead of GPS",
      example: "1"
    )

    field(5, :sdm_ant_id_trans_type, :uint8z, example: "1")

    field(7, :odometer_rollover, :uint8,
      comment: "Rollover counter that can be used to extend the odometer",
      example: "1"
    )
  end

  message(:bike_profile) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :name, :string, example: "16")
    field(1, :sport, :sport, example: "1")
    field(2, :sub_sport, :sub_sport, example: "1")
    field(3, :odometer, :uint32, example: "1", scale: ~c"d", units: ["m"])
    field(4, :bike_spd_ant_id, :uint16z, example: "1")
    field(5, :bike_cad_ant_id, :uint16z, example: "1")
    field(6, :bike_spdcad_ant_id, :uint16z, example: "1")
    field(7, :bike_power_ant_id, :uint16z, example: "1")
    field(8, :custom_wheelsize, :uint16, example: "1", scale: [1000], units: ["m"])
    field(9, :auto_wheelsize, :uint16, example: "1", scale: [1000], units: ["m"])
    field(10, :bike_weight, :uint16, example: "1", scale: ~c"\n", units: ["kg"])
    field(11, :power_cal_factor, :uint16, example: "1", scale: ~c"\n", units: ["%"])
    field(12, :auto_wheel_cal, :bool, example: "1")
    field(13, :auto_power_zero, :bool, example: "1")
    field(14, :id, :uint8, example: "1")
    field(15, :spd_enabled, :bool, example: "1")
    field(16, :cad_enabled, :bool, example: "1")
    field(17, :spdcad_enabled, :bool, example: "1")
    field(18, :power_enabled, :bool, example: "1")
    field(19, :crank_length, :uint8, example: "1", offset: [-110], scale: [2], units: ["mm"])
    field(20, :enabled, :bool, example: "1")
    field(21, :bike_spd_ant_id_trans_type, :uint8z, example: "1")
    field(22, :bike_cad_ant_id_trans_type, :uint8z, example: "1")
    field(23, :bike_spdcad_ant_id_trans_type, :uint8z, example: "1")
    field(24, :bike_power_ant_id_trans_type, :uint8z, example: "1")

    field(37, :odometer_rollover, :uint8,
      comment: "Rollover counter that can be used to extend the odometer",
      example: "1"
    )

    field(38, :front_gear_num, :uint8z, comment: "Number of front gears", example: "1")

    field(39, :front_gear, :uint8z,
      array: true,
      comment: "Number of teeth on each gear 0 is innermost",
      example: "1"
    )

    field(40, :rear_gear_num, :uint8z, comment: "Number of rear gears", example: "1")

    field(41, :rear_gear, :uint8z,
      array: true,
      comment: "Number of teeth on each gear 0 is innermost",
      example: "1"
    )

    field(44, :shimano_di2_enabled, :bool, example: "1")
  end

  message(:connectivity) do
    field(0, :bluetooth_enabled, :bool,
      comment: "Use Bluetooth for connectivity features",
      example: "1"
    )

    field(1, :bluetooth_le_enabled, :bool,
      comment: "Use Bluetooth Low Energy for connectivity features",
      example: "1"
    )

    field(2, :ant_enabled, :bool, comment: "Use ANT for connectivity features", example: "1")
    field(3, :name, :string, example: "24")
    field(4, :live_tracking_enabled, :bool, example: "1")
    field(5, :weather_conditions_enabled, :bool, example: "1")
    field(6, :weather_alerts_enabled, :bool, example: "1")
    field(7, :auto_activity_upload_enabled, :bool, example: "1")
    field(8, :course_download_enabled, :bool, example: "1")
    field(9, :workout_download_enabled, :bool, example: "1")
    field(10, :gps_ephemeris_download_enabled, :bool, example: "1")
    field(11, :incident_detection_enabled, :bool, example: "1")
    field(12, :grouptrack_enabled, :bool, example: "1")
  end

  message(:watchface_settings) do
    field(254, :message_index, :message_index)
    field(0, :mode, :watchface_mode)

    field(1, :layout, :byte,
      subfields: [
        %{name: :analog_layout, ref_fields: [mode: "analog"], type: :analog_watchface_layout},
        %{name: :digital_layout, ref_fields: [mode: "digital"], type: :digital_watchface_layout}
      ]
    )
  end

  message(:ohr_settings) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :enabled, :switch)
  end

  message(:time_in_zone) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :reference_mesg, :mesg_num)
    field(1, :reference_index, :message_index)
    field(2, :time_in_hr_zone, :uint32, array: true, scale: [1000], units: ["s"])
    field(3, :time_in_speed_zone, :uint32, array: true, scale: [1000], units: ["s"])
    field(4, :time_in_cadence_zone, :uint32, array: true, scale: [1000], units: ["s"])
    field(5, :time_in_power_zone, :uint32, array: true, scale: [1000], units: ["s"])
    field(6, :hr_zone_high_boundary, :uint8, array: true, units: ["bpm"])
    field(7, :speed_zone_high_boundary, :uint16, array: true, scale: [1000], units: ["m/s"])
    field(8, :cadence_zone_high_bondary, :uint8, array: true, units: ["rpm"])
    field(9, :power_zone_high_boundary, :uint16, array: true, units: ["watts"])
    field(10, :hr_calc_type, :hr_zone_calc)
    field(11, :max_heart_rate, :uint8)
    field(12, :resting_heart_rate, :uint8)
    field(13, :threshold_heart_rate, :uint8)
    field(14, :pwr_calc_type, :pwr_zone_calc)
    field(15, :functional_threshold_power, :uint16)
  end

  message(:zones_target) do
    field(1, :max_heart_rate, :uint8, example: "1")
    field(2, :threshold_heart_rate, :uint8, example: "1")
    field(3, :functional_threshold_power, :uint16, example: "1")
    field(5, :hr_calc_type, :hr_zone_calc, example: "1")
    field(7, :pwr_calc_type, :pwr_zone_calc, example: "1")
  end

  message(:sport) do
    field(0, :sport, :sport, example: "1")
    field(1, :sub_sport, :sub_sport, example: "1")
    field(3, :name, :string, example: "16")
  end

  message(:hr_zone) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :high_bpm, :uint8, example: "1", units: ["bpm"])
    field(2, :name, :string, example: "16")
  end

  message(:speed_zone) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :high_value, :uint16, example: "1", scale: [1000], units: ["m/s"])
    field(1, :name, :string, example: "16")
  end

  message(:cadence_zone) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :high_value, :uint8, example: "1", units: ["rpm"])
    field(1, :name, :string, example: "16")
  end

  message(:power_zone) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :high_value, :uint16, example: "1", units: ["watts"])
    field(2, :name, :string, example: "16")
  end

  message(:met_zone) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :high_bpm, :uint8, example: "1")
    field(2, :calories, :uint16, example: "1", scale: ~c"\n", units: ["kcal / min"])
    field(3, :fat_calories, :uint8, example: "1", scale: ~c"\n", units: ["kcal / min"])
  end

  message(:dive_settings) do
    field(253, :timestamp, :date_time)
    field(254, :message_index, :message_index)
    field(0, :name, :string, example: "16")
    field(1, :model, :tissue_model_type)
    field(2, :gf_low, :uint8, units: ["percent"])
    field(3, :gf_high, :uint8, units: ["percent"])
    field(4, :water_type, :water_type)

    field(5, :water_density, :float32,
      comment: "Fresh water is usually 1000; salt water is usually 1025",
      units: ["kg/m^3"]
    )

    field(6, :po2_warn, :uint8, comment: "Typically 1.40", scale: ~c"d", units: ["percent"])
    field(7, :po2_critical, :uint8, comment: "Typically 1.60", scale: ~c"d", units: ["percent"])
    field(8, :po2_deco, :uint8, scale: ~c"d", units: ["percent"])
    field(9, :safety_stop_enabled, :bool)
    field(10, :bottom_depth, :float32)
    field(11, :bottom_time, :uint32)
    field(12, :apnea_countdown_enabled, :bool)
    field(13, :apnea_countdown_time, :uint32)
    field(14, :backlight_mode, :dive_backlight_mode)
    field(15, :backlight_brightness, :uint8)
    field(16, :backlight_timeout, :backlight_timeout)

    field(17, :repeat_dive_interval, :uint16,
      comment: "Time between surfacing and ending the activity",
      scale: [1],
      units: ["s"]
    )

    field(18, :safety_stop_time, :uint16,
      comment: "Time at safety stop (if enabled)",
      scale: [1],
      units: ["s"]
    )

    field(19, :heart_rate_source_type, :source_type)

    field(20, :heart_rate_source, :uint8,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :heart_rate_local_device_type,
          ref_fields: [heart_rate_source_type: "local"],
          type: :local_device_type
        },
        %{
          example: "1",
          name: :heart_rate_antplus_device_type,
          ref_fields: [heart_rate_source_type: "antplus"],
          type: :antplus_device_type
        }
      ]
    )

    field(21, :travel_gas, :message_index, comment: "Index of travel dive_gas message")

    field(22, :ccr_low_setpoint_switch_mode, :ccr_setpoint_switch_mode,
      comment: "If low PO2 should be switched to automatically"
    )

    field(23, :ccr_low_setpoint, :uint8,
      comment: "Target PO2 when using low setpoint",
      scale: ~c"d",
      units: ["percent"]
    )

    field(24, :ccr_low_setpoint_depth, :uint32,
      comment: "Depth to switch to low setpoint in automatic mode",
      scale: [1000],
      units: ["m"]
    )

    field(25, :ccr_high_setpoint_switch_mode, :ccr_setpoint_switch_mode,
      comment: "If high PO2 should be switched to automatically"
    )

    field(26, :ccr_high_setpoint, :uint8,
      comment: "Target PO2 when using high setpoint",
      scale: ~c"d",
      units: ["percent"]
    )

    field(27, :ccr_high_setpoint_depth, :uint32,
      comment: "Depth to switch to high setpoint in automatic mode",
      scale: [1000],
      units: ["m"]
    )

    field(29, :gas_consumption_display, :gas_consumption_rate_type,
      comment: "Type of gas consumption rate to display. Some values are only valid if tank volume is known."
    )

    field(30, :up_key_enabled, :bool, comment: "Indicates whether the up key is enabled during dives")

    field(35, :dive_sounds, :tone, comment: "Sounds and vibration enabled or disabled in-dive")

    field(36, :last_stop_multiple, :uint8,
      comment: "Usually 1.0/1.5/2.0 representing 3/4.5/6m or 10/15/20ft",
      scale: ~c"\n"
    )

    field(37, :no_fly_time_mode, :no_fly_time_mode,
      comment: "Indicates which guidelines to use for no-fly surface interval."
    )
  end

  message(:dive_alarm) do
    field(254, :message_index, :message_index, comment: "Index of the alarm")

    field(0, :depth, :uint32,
      comment: "Depth setting (m) for depth type alarms",
      scale: [1000],
      units: ["m"]
    )

    field(1, :time, :sint32,
      comment: "Time setting (s) for time type alarms",
      scale: [1],
      units: ["s"]
    )

    field(2, :enabled, :bool, comment: "Enablement flag")
    field(3, :alarm_type, :dive_alarm_type, comment: "Alarm type setting")
    field(4, :sound, :tone, comment: "Tone and Vibe setting for the alarm")

    field(5, :dive_types, :sub_sport,
      array: true,
      comment: "Dive types the alarm will trigger on"
    )

    field(6, :id, :uint32, comment: "Alarm ID")
    field(7, :popup_enabled, :bool, comment: "Show a visible pop-up for this alarm")
    field(8, :trigger_on_descent, :bool, comment: "Trigger the alarm on descent")
    field(9, :trigger_on_ascent, :bool, comment: "Trigger the alarm on ascent")
    field(10, :repeating, :bool, comment: "Repeat alarm each time threshold is crossed?")

    field(11, :speed, :sint32,
      comment: "Ascent/descent rate (mps) setting for speed type alarms",
      scale: [1000],
      units: ["mps"]
    )
  end

  message(:dive_apnea_alarm) do
    field(254, :message_index, :message_index, comment: "Index of the alarm")

    field(0, :depth, :uint32,
      comment: "Depth setting (m) for depth type alarms",
      scale: [1000],
      units: ["m"]
    )

    field(1, :time, :sint32,
      comment: "Time setting (s) for time type alarms",
      scale: [1],
      units: ["s"]
    )

    field(2, :enabled, :bool, comment: "Enablement flag")
    field(3, :alarm_type, :dive_alarm_type, comment: "Alarm type setting")
    field(4, :sound, :tone, comment: "Tone and Vibe setting for the alarm.")

    field(5, :dive_types, :sub_sport,
      array: true,
      comment: "Dive types the alarm will trigger on"
    )

    field(6, :id, :uint32, comment: "Alarm ID")
    field(7, :popup_enabled, :bool, comment: "Show a visible pop-up for this alarm")
    field(8, :trigger_on_descent, :bool, comment: "Trigger the alarm on descent")
    field(9, :trigger_on_ascent, :bool, comment: "Trigger the alarm on ascent")
    field(10, :repeating, :bool, comment: "Repeat alarm each time threshold is crossed?")

    field(11, :speed, :sint32,
      comment: "Ascent/descent rate (mps) setting for speed type alarms",
      scale: [1000],
      units: ["mps"]
    )
  end

  message(:dive_gas) do
    field(254, :message_index, :message_index)
    field(0, :helium_content, :uint8, units: ["percent"])
    field(1, :oxygen_content, :uint8, units: ["percent"])
    field(2, :status, :dive_gas_status)
    field(3, :mode, :dive_gas_mode)
  end

  message(:goal) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :sport, :sport, example: "1")
    field(1, :sub_sport, :sub_sport, example: "1")
    field(2, :start_date, :date_time, example: "1")
    field(3, :end_date, :date_time, example: "1")
    field(4, :type, :goal, example: "1")
    field(5, :value, :uint32, example: "1")
    field(6, :repeat, :bool, example: "1")
    field(7, :target_value, :uint32, example: "1")
    field(8, :recurrence, :goal_recurrence, example: "1")
    field(9, :recurrence_value, :uint16, example: "1")
    field(10, :enabled, :bool, example: "1")
    field(11, :source, :goal_source, example: "1")
  end

  message(:activity) do
    field(253, :timestamp, :date_time, example: "1")

    field(0, :total_timer_time, :uint32,
      comment: "Exclude pauses",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(1, :num_sessions, :uint16, example: "1")
    field(2, :type, :activity, example: "1")
    field(3, :event, :event, example: "1")
    field(4, :event_type, :event_type, example: "1")

    field(5, :local_timestamp, :local_date_time,
      comment: "timestamp epoch expressed in local time, used to convert activity timestamps to local time",
      example: "1"
    )

    field(6, :event_group, :uint8, example: "1")
  end

  message(:session) do
    field(254, :message_index, :message_index,
      comment: "Selected bit is set for the current session.",
      example: "1"
    )

    field(253, :timestamp, :date_time, comment: "Sesson end time.", example: "1", units: ["s"])
    field(0, :event, :event, comment: "session", example: "1")
    field(1, :event_type, :event_type, comment: "stop", example: "1")
    field(2, :start_time, :date_time, example: "1")
    field(3, :start_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(4, :start_position_long, :sint32, example: "1", units: ["semicircles"])
    field(5, :sport, :sport, example: "1")
    field(6, :sub_sport, :sub_sport, example: "1")

    field(7, :total_elapsed_time, :uint32,
      comment: "Time (includes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(8, :total_timer_time, :uint32,
      comment: "Timer Time (excludes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(9, :total_distance, :uint32, example: "1", scale: ~c"d", units: ["m"])

    field(10, :total_cycles, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :total_strokes,
          ref_fields: [sport: "cycling", sport: "swimming", sport: "rowing", sport: "stand_up_paddleboarding"],
          type: :uint32,
          units: ["strokes"]
        },
        %{
          example: "1",
          name: :total_strides,
          ref_fields: [sport: "running", sport: "walking"],
          type: :uint32,
          units: ["strides"]
        }
      ],
      units: ["cycles"]
    )

    field(11, :total_calories, :uint16, example: "1", units: ["kcal"])
    field(13, :total_fat_calories, :uint16, example: "1", units: ["kcal"])

    field(14, :avg_speed, :uint16,
      bits: [16],
      comment: "total_distance / total_timer_time",
      components: [:enhanced_avg_speed],
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(15, :max_speed, :uint16,
      bits: [16],
      components: [:enhanced_max_speed],
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(16, :avg_heart_rate, :uint8,
      comment: "average heart rate (excludes pause time)",
      example: "1",
      units: ["bpm"]
    )

    field(17, :max_heart_rate, :uint8, example: "1", units: ["bpm"])

    field(18, :avg_cadence, :uint8,
      comment: "total_cycles / total_timer_time if non_zero_avg_cadence otherwise total_cycles / total_elapsed_time",
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :avg_running_cadence,
          ref_fields: [sport: "running"],
          type: :uint8,
          units: ["strides/min"]
        }
      ],
      units: ["rpm"]
    )

    field(19, :max_cadence, :uint8,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :max_running_cadence,
          ref_fields: [sport: "running"],
          type: :uint8,
          units: ["strides/min"]
        }
      ],
      units: ["rpm"]
    )

    field(20, :avg_power, :uint16,
      comment: "total_power / total_timer_time if non_zero_avg_power otherwise total_power / total_elapsed_time",
      example: "1",
      units: ["watts"]
    )

    field(21, :max_power, :uint16, example: "1", units: ["watts"])
    field(22, :total_ascent, :uint16, example: "1", units: ["m"])
    field(23, :total_descent, :uint16, example: "1", units: ["m"])
    field(24, :total_training_effect, :uint8, example: "1", scale: ~c"\n")
    field(25, :first_lap_index, :uint16, example: "1")
    field(26, :num_laps, :uint16, example: "1")
    field(27, :event_group, :uint8, example: "1")
    field(28, :trigger, :session_trigger, example: "1")

    field(29, :nec_lat, :sint32,
      comment: "North east corner latitude",
      example: "1",
      units: ["semicircles"]
    )

    field(30, :nec_long, :sint32,
      comment: "North east corner longitude",
      example: "1",
      units: ["semicircles"]
    )

    field(31, :swc_lat, :sint32,
      comment: "South west corner latitude",
      example: "1",
      units: ["semicircles"]
    )

    field(32, :swc_long, :sint32,
      comment: "South west corner longitude",
      example: "1",
      units: ["semicircles"]
    )

    field(33, :num_lengths, :uint16,
      comment: "# of lengths of swim pool",
      example: "1",
      units: ["lengths"]
    )

    field(34, :normalized_power, :uint16, example: "1", units: ["watts"])
    field(35, :training_stress_score, :uint16, example: "1", scale: ~c"\n", units: ["tss"])
    field(36, :intensity_factor, :uint16, example: "1", scale: [1000], units: ["if"])
    field(37, :left_right_balance, :left_right_balance_100, example: "1")
    field(38, :end_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(39, :end_position_long, :sint32, example: "1", units: ["semicircles"])
    field(41, :avg_stroke_count, :uint32, example: "1", scale: ~c"\n", units: ["strokes/lap"])
    field(42, :avg_stroke_distance, :uint16, example: "1", scale: ~c"d", units: ["m"])
    field(43, :swim_stroke, :swim_stroke, example: "1", units: ["swim_stroke"])
    field(44, :pool_length, :uint16, example: "1", scale: ~c"d", units: ["m"])
    field(45, :threshold_power, :uint16, example: "1", units: ["watts"])
    field(46, :pool_length_unit, :display_measure, example: "1")

    field(47, :num_active_lengths, :uint16,
      comment: "# of active lengths of swim pool",
      example: "1",
      units: ["lengths"]
    )

    field(48, :total_work, :uint32, example: "1", units: ["J"])

    field(49, :avg_altitude, :uint16,
      bits: [16],
      components: [:enhanced_avg_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(50, :max_altitude, :uint16,
      bits: [16],
      components: [:enhanced_max_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(51, :gps_accuracy, :uint8, example: "1", units: ["m"])
    field(52, :avg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(53, :avg_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(54, :avg_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(55, :max_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(56, :max_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(57, :avg_temperature, :sint8, example: "1", units: ["C"])
    field(58, :max_temperature, :sint8, example: "1", units: ["C"])
    field(59, :total_moving_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(60, :avg_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(61, :avg_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(62, :max_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(63, :max_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(64, :min_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(65, :time_in_hr_zone, :uint32, array: true, example: "1", scale: [1000], units: ["s"])

    field(66, :time_in_speed_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(67, :time_in_cadence_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(68, :time_in_power_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(69, :avg_lap_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(70, :best_lap_index, :uint16, example: "1")

    field(71, :min_altitude, :uint16,
      bits: [16],
      components: [:enhanced_min_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(82, :player_score, :uint16, example: "1")
    field(83, :opponent_score, :uint16, example: "1")
    field(84, :opponent_name, :string, example: "1")

    field(85, :stroke_count, :uint16,
      array: true,
      comment: "stroke_type enum used as the index",
      example: "1",
      units: ["counts"]
    )

    field(86, :zone_count, :uint16,
      array: true,
      comment: "zone number used as the index",
      example: "1",
      units: ["counts"]
    )

    field(87, :max_ball_speed, :uint16, example: "1", scale: ~c"d", units: ["m/s"])
    field(88, :avg_ball_speed, :uint16, example: "1", scale: ~c"d", units: ["m/s"])
    field(89, :avg_vertical_oscillation, :uint16, example: "1", scale: ~c"\n", units: ["mm"])
    field(90, :avg_stance_time_percent, :uint16, example: "1", scale: ~c"d", units: ["percent"])
    field(91, :avg_stance_time, :uint16, example: "1", scale: ~c"\n", units: ["ms"])

    field(92, :avg_fractional_cadence, :uint8,
      comment: "fractional part of the avg_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(93, :max_fractional_cadence, :uint8,
      comment: "fractional part of the max_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(94, :total_fractional_cycles, :uint8,
      comment: "fractional part of the total_cycles",
      example: "1",
      scale: [128],
      units: ["cycles"]
    )

    field(95, :avg_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Avg saturated and unsaturated hemoglobin",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(96, :min_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Min saturated and unsaturated hemoglobin",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(97, :max_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Max saturated and unsaturated hemoglobin",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(98, :avg_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Avg percentage of hemoglobin saturated with oxygen",
      scale: ~c"\n",
      units: ["%"]
    )

    field(99, :min_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Min percentage of hemoglobin saturated with oxygen",
      scale: ~c"\n",
      units: ["%"]
    )

    field(100, :max_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Max percentage of hemoglobin saturated with oxygen",
      scale: ~c"\n",
      units: ["%"]
    )

    field(101, :avg_left_torque_effectiveness, :uint8, scale: [2], units: ["percent"])
    field(102, :avg_right_torque_effectiveness, :uint8, scale: [2], units: ["percent"])
    field(103, :avg_left_pedal_smoothness, :uint8, scale: [2], units: ["percent"])
    field(104, :avg_right_pedal_smoothness, :uint8, scale: [2], units: ["percent"])
    field(105, :avg_combined_pedal_smoothness, :uint8, scale: [2], units: ["percent"])

    field(110, :sport_profile_name, :string,
      comment: "Sport name from associated sport mesg",
      example: "16"
    )

    field(111, :sport_index, :uint8, example: "1")

    field(112, :time_standing, :uint32,
      comment: "Total time spend in the standing position",
      scale: [1000],
      units: ["s"]
    )

    field(113, :stand_count, :uint16, comment: "Number of transitions to the standing state")

    field(114, :avg_left_pco, :sint8,
      comment: "Average platform center offset Left",
      units: ["mm"]
    )

    field(115, :avg_right_pco, :sint8,
      comment: "Average platform center offset Right",
      units: ["mm"]
    )

    field(116, :avg_left_power_phase, :uint8,
      array: true,
      comment: "Average left power phase angles. Indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(117, :avg_left_power_phase_peak, :uint8,
      array: true,
      comment: "Average left power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(118, :avg_right_power_phase, :uint8,
      array: true,
      comment: "Average right power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(119, :avg_right_power_phase_peak, :uint8,
      array: true,
      comment: "Average right power phase peak angles data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(120, :avg_power_position, :uint16,
      array: true,
      comment: "Average power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(121, :max_power_position, :uint16,
      array: true,
      comment: "Maximum power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(122, :avg_cadence_position, :uint8,
      array: true,
      comment: "Average cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(123, :max_cadence_position, :uint8,
      array: true,
      comment: "Maximum cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(124, :enhanced_avg_speed, :uint32,
      comment: "total_distance / total_timer_time",
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(125, :enhanced_max_speed, :uint32, example: "1", scale: [1000], units: ["m/s"])

    field(126, :enhanced_avg_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(127, :enhanced_min_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(128, :enhanced_max_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(129, :avg_lev_motor_power, :uint16,
      comment: "lev average motor power during session",
      units: ["watts"]
    )

    field(130, :max_lev_motor_power, :uint16,
      comment: "lev maximum motor power during session",
      units: ["watts"]
    )

    field(131, :lev_battery_consumption, :uint8,
      comment: "lev battery consumption during session",
      scale: [2],
      units: ["percent"]
    )

    field(132, :avg_vertical_ratio, :uint16, scale: ~c"d", units: ["percent"])
    field(133, :avg_stance_time_balance, :uint16, scale: ~c"d", units: ["percent"])
    field(134, :avg_step_length, :uint16, scale: ~c"\n", units: ["mm"])
    field(137, :total_anaerobic_training_effect, :uint8, example: "1", scale: ~c"\n")
    field(139, :avg_vam, :uint16, bits: [16], example: "1", scale: [1000], units: ["m/s"])
    field(140, :avg_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(141, :max_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])

    field(142, :surface_interval, :uint32,
      comment: "Time since end of last dive",
      scale: [1],
      units: ["s"]
    )

    field(143, :start_cns, :uint8, scale: [1], units: ["percent"])
    field(144, :end_cns, :uint8, scale: [1], units: ["percent"])
    field(145, :start_n2, :uint16, scale: [1], units: ["percent"])
    field(146, :end_n2, :uint16, scale: [1], units: ["percent"])

    field(147, :avg_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_avg_respiration_rate]
    )

    field(148, :max_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_max_respiration_rate]
    )

    field(149, :min_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_min_respiration_rate]
    )

    field(150, :min_temperature, :sint8, example: "1", units: ["C"])
    field(155, :o2_toxicity, :uint16, units: ["OTUs"])
    field(156, :dive_number, :uint32)
    field(168, :training_load_peak, :sint32, scale: [65536])
    field(169, :enhanced_avg_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])
    field(170, :enhanced_max_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])
    field(180, :enhanced_min_respiration_rate, :uint16, scale: ~c"d")

    field(181, :total_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(182, :total_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(183, :jump_count, :uint16)

    field(186, :avg_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(187, :avg_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(194, :avg_spo2, :uint8,
      comment: "Average SPO2 for the monitoring session",
      units: ["percent"]
    )

    field(195, :avg_stress, :uint8,
      comment: "Average stress for the monitoring session",
      units: ["percent"]
    )

    field(197, :sdrr_hrv, :uint8,
      comment:
        "Standard deviation of R-R interval (SDRR) - Heart rate variability measure most useful for wellness users.",
      units: ["mS"]
    )

    field(198, :rmssd_hrv, :uint8,
      comment:
        "Root mean square successive difference (RMSSD) - Heart rate variability measure most useful for athletes",
      units: ["mS"]
    )

    field(199, :total_fractional_ascent, :uint8,
      comment: "fractional part of total_ascent",
      scale: ~c"d",
      units: ["m"]
    )

    field(200, :total_fractional_descent, :uint8,
      comment: "fractional part of total_descent",
      scale: ~c"d",
      units: ["m"]
    )

    field(208, :avg_core_temperature, :uint16, scale: ~c"d", units: ["C"])
    field(209, :min_core_temperature, :uint16, scale: ~c"d", units: ["C"])
    field(210, :max_core_temperature, :uint16, scale: ~c"d", units: ["C"])
  end

  message(:lap) do
    field(254, :message_index, :message_index, example: "1")
    field(253, :timestamp, :date_time, comment: "Lap end time.", example: "1", units: ["s"])
    field(0, :event, :event, example: "1")
    field(1, :event_type, :event_type, example: "1")
    field(2, :start_time, :date_time, example: "1")
    field(3, :start_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(4, :start_position_long, :sint32, example: "1", units: ["semicircles"])
    field(5, :end_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(6, :end_position_long, :sint32, example: "1", units: ["semicircles"])

    field(7, :total_elapsed_time, :uint32,
      comment: "Time (includes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(8, :total_timer_time, :uint32,
      comment: "Timer Time (excludes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(9, :total_distance, :uint32, example: "1", scale: ~c"d", units: ["m"])

    field(10, :total_cycles, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :total_strokes,
          ref_fields: [sport: "cycling", sport: "swimming", sport: "rowing", sport: "stand_up_paddleboarding"],
          type: :uint32,
          units: ["strokes"]
        },
        %{
          example: "1",
          name: :total_strides,
          ref_fields: [sport: "running", sport: "walking"],
          type: :uint32,
          units: ["strides"]
        }
      ],
      units: ["cycles"]
    )

    field(11, :total_calories, :uint16, example: "1", units: ["kcal"])
    field(12, :total_fat_calories, :uint16, comment: "If New Leaf", example: "1", units: ["kcal"])

    field(13, :avg_speed, :uint16,
      bits: [16],
      components: [:enhanced_avg_speed],
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(14, :max_speed, :uint16,
      bits: [16],
      components: [:enhanced_max_speed],
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(15, :avg_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(16, :max_heart_rate, :uint8, example: "1", units: ["bpm"])

    field(17, :avg_cadence, :uint8,
      comment: "total_cycles / total_timer_time if non_zero_avg_cadence otherwise total_cycles / total_elapsed_time",
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :avg_running_cadence,
          ref_fields: [sport: "running"],
          type: :uint8,
          units: ["strides/min"]
        }
      ],
      units: ["rpm"]
    )

    field(18, :max_cadence, :uint8,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :max_running_cadence,
          ref_fields: [sport: "running"],
          type: :uint8,
          units: ["strides/min"]
        }
      ],
      units: ["rpm"]
    )

    field(19, :avg_power, :uint16,
      comment: "total_power / total_timer_time if non_zero_avg_power otherwise total_power / total_elapsed_time",
      example: "1",
      units: ["watts"]
    )

    field(20, :max_power, :uint16, example: "1", units: ["watts"])
    field(21, :total_ascent, :uint16, example: "1", units: ["m"])
    field(22, :total_descent, :uint16, example: "1", units: ["m"])
    field(23, :intensity, :intensity, example: "1")
    field(24, :lap_trigger, :lap_trigger, example: "1")
    field(25, :sport, :sport, example: "1")
    field(26, :event_group, :uint8, example: "1")

    field(32, :num_lengths, :uint16,
      comment: "# of lengths of swim pool",
      example: "1",
      units: ["lengths"]
    )

    field(33, :normalized_power, :uint16, example: "1", units: ["watts"])
    field(34, :left_right_balance, :left_right_balance_100, example: "1")
    field(35, :first_length_index, :uint16, example: "1")
    field(37, :avg_stroke_distance, :uint16, example: "1", scale: ~c"d", units: ["m"])
    field(38, :swim_stroke, :swim_stroke, example: "1")
    field(39, :sub_sport, :sub_sport, example: "1")

    field(40, :num_active_lengths, :uint16,
      comment: "# of active lengths of swim pool",
      example: "1",
      units: ["lengths"]
    )

    field(41, :total_work, :uint32, example: "1", units: ["J"])

    field(42, :avg_altitude, :uint16,
      bits: [16],
      components: [:enhanced_avg_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(43, :max_altitude, :uint16,
      bits: [16],
      components: [:enhanced_max_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(44, :gps_accuracy, :uint8, example: "1", units: ["m"])
    field(45, :avg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(46, :avg_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(47, :avg_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(48, :max_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(49, :max_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(50, :avg_temperature, :sint8, example: "1", units: ["C"])
    field(51, :max_temperature, :sint8, example: "1", units: ["C"])
    field(52, :total_moving_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(53, :avg_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(54, :avg_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(55, :max_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(56, :max_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(57, :time_in_hr_zone, :uint32, array: true, example: "1", scale: [1000], units: ["s"])

    field(58, :time_in_speed_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(59, :time_in_cadence_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(60, :time_in_power_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(61, :repetition_num, :uint16, example: "1")

    field(62, :min_altitude, :uint16,
      bits: [16],
      components: [:enhanced_min_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(63, :min_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(71, :wkt_step_index, :message_index, example: "1")
    field(74, :opponent_score, :uint16, example: "1")

    field(75, :stroke_count, :uint16,
      array: true,
      comment: "stroke_type enum used as the index",
      example: "1",
      units: ["counts"]
    )

    field(76, :zone_count, :uint16,
      array: true,
      comment: "zone number used as the index",
      example: "1",
      units: ["counts"]
    )

    field(77, :avg_vertical_oscillation, :uint16, example: "1", scale: ~c"\n", units: ["mm"])
    field(78, :avg_stance_time_percent, :uint16, example: "1", scale: ~c"d", units: ["percent"])
    field(79, :avg_stance_time, :uint16, example: "1", scale: ~c"\n", units: ["ms"])

    field(80, :avg_fractional_cadence, :uint8,
      comment: "fractional part of the avg_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(81, :max_fractional_cadence, :uint8,
      comment: "fractional part of the max_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(82, :total_fractional_cycles, :uint8,
      comment: "fractional part of the total_cycles",
      example: "1",
      scale: [128],
      units: ["cycles"]
    )

    field(83, :player_score, :uint16, example: "1")

    field(84, :avg_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Avg saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(85, :min_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Min saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(86, :max_total_hemoglobin_conc, :uint16,
      array: true,
      comment: "Max saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(87, :avg_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Avg percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(88, :min_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Min percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(89, :max_saturated_hemoglobin_percent, :uint16,
      array: true,
      comment: "Max percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(91, :avg_left_torque_effectiveness, :uint8, scale: [2], units: ["percent"])
    field(92, :avg_right_torque_effectiveness, :uint8, scale: [2], units: ["percent"])
    field(93, :avg_left_pedal_smoothness, :uint8, scale: [2], units: ["percent"])
    field(94, :avg_right_pedal_smoothness, :uint8, scale: [2], units: ["percent"])
    field(95, :avg_combined_pedal_smoothness, :uint8, scale: [2], units: ["percent"])

    field(98, :time_standing, :uint32,
      comment: "Total time spent in the standing position",
      scale: [1000],
      units: ["s"]
    )

    field(99, :stand_count, :uint16, comment: "Number of transitions to the standing state")

    field(100, :avg_left_pco, :sint8,
      comment: "Average left platform center offset",
      units: ["mm"]
    )

    field(101, :avg_right_pco, :sint8,
      comment: "Average right platform center offset",
      units: ["mm"]
    )

    field(102, :avg_left_power_phase, :uint8,
      array: true,
      comment: "Average left power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(103, :avg_left_power_phase_peak, :uint8,
      array: true,
      comment: "Average left power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(104, :avg_right_power_phase, :uint8,
      array: true,
      comment: "Average right power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(105, :avg_right_power_phase_peak, :uint8,
      array: true,
      comment: "Average right power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(106, :avg_power_position, :uint16,
      array: true,
      comment: "Average power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(107, :max_power_position, :uint16,
      array: true,
      comment: "Maximum power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(108, :avg_cadence_position, :uint8,
      array: true,
      comment: "Average cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(109, :max_cadence_position, :uint8,
      array: true,
      comment: "Maximum cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(110, :enhanced_avg_speed, :uint32, example: "1", scale: [1000], units: ["m/s"])
    field(111, :enhanced_max_speed, :uint32, example: "1", scale: [1000], units: ["m/s"])

    field(112, :enhanced_avg_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(113, :enhanced_min_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(114, :enhanced_max_altitude, :uint32,
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(115, :avg_lev_motor_power, :uint16,
      comment: "lev average motor power during lap",
      units: ["watts"]
    )

    field(116, :max_lev_motor_power, :uint16,
      comment: "lev maximum motor power during lap",
      units: ["watts"]
    )

    field(117, :lev_battery_consumption, :uint8,
      comment: "lev battery consumption during lap",
      scale: [2],
      units: ["percent"]
    )

    field(118, :avg_vertical_ratio, :uint16, scale: ~c"d", units: ["percent"])
    field(119, :avg_stance_time_balance, :uint16, scale: ~c"d", units: ["percent"])
    field(120, :avg_step_length, :uint16, scale: ~c"\n", units: ["mm"])
    field(121, :avg_vam, :uint16, bits: [16], example: "1", scale: [1000], units: ["m/s"])
    field(122, :avg_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(123, :max_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(124, :min_temperature, :sint8, example: "1", units: ["C"])
    field(136, :enhanced_avg_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])
    field(137, :enhanced_max_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])

    field(147, :avg_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_avg_respiration_rate]
    )

    field(148, :max_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_max_respiration_rate]
    )

    field(149, :total_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(150, :total_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(151, :jump_count, :uint16)

    field(153, :avg_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(154, :avg_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(156, :total_fractional_ascent, :uint8,
      comment: "fractional part of total_ascent",
      scale: ~c"d",
      units: ["m"]
    )

    field(157, :total_fractional_descent, :uint8,
      comment: "fractional part of total_descent",
      scale: ~c"d",
      units: ["m"]
    )

    field(158, :avg_core_temperature, :uint16, scale: ~c"d", units: ["C"])
    field(159, :min_core_temperature, :uint16, scale: ~c"d", units: ["C"])
    field(160, :max_core_temperature, :uint16, scale: ~c"d", units: ["C"])
  end

  message(:length) do
    field(254, :message_index, :message_index, example: "1")
    field(253, :timestamp, :date_time, example: "1")
    field(0, :event, :event, example: "1")
    field(1, :event_type, :event_type, example: "1")
    field(2, :start_time, :date_time, example: "1")
    field(3, :total_elapsed_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(4, :total_timer_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(5, :total_strokes, :uint16, example: "1", units: ["strokes"])
    field(6, :avg_speed, :uint16, example: "1", scale: [1000], units: ["m/s"])
    field(7, :swim_stroke, :swim_stroke, example: "1", units: ["swim_stroke"])
    field(9, :avg_swimming_cadence, :uint8, example: "1", units: ["strokes/min"])
    field(10, :event_group, :uint8, example: "1")
    field(11, :total_calories, :uint16, example: "1", units: ["kcal"])
    field(12, :length_type, :length_type, example: "1")
    field(18, :player_score, :uint16, example: "1")
    field(19, :opponent_score, :uint16, example: "1")

    field(20, :stroke_count, :uint16,
      array: true,
      comment: "stroke_type enum used as the index",
      example: "1",
      units: ["counts"]
    )

    field(21, :zone_count, :uint16,
      array: true,
      comment: "zone number used as the index",
      example: "1",
      units: ["counts"]
    )

    field(22, :enhanced_avg_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])
    field(23, :enhanced_max_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])

    field(24, :avg_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_avg_respiration_rate]
    )

    field(25, :max_respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_max_respiration_rate]
    )
  end

  message(:record) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :position_lat, :sint32, example: "1", units: ["semicircles"])
    field(1, :position_long, :sint32, example: "1", units: ["semicircles"])

    field(2, :altitude, :uint16,
      bits: [16],
      components: [:enhanced_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(3, :heart_rate, :uint8, example: "1", units: ["bpm"])
    field(4, :cadence, :uint8, example: "1", units: ["rpm"])
    field(5, :distance, :uint32, example: "1", scale: ~c"d", units: ["m"])

    field(6, :speed, :uint16,
      bits: [16],
      components: [:enhanced_speed],
      example: "1",
      scale: [1000],
      units: ["m/s"]
    )

    field(7, :power, :uint16, example: "1", units: ["watts"])

    field(8, :compressed_speed_distance, :byte,
      accumulate: [false, true],
      array: 3,
      bits: ~c"\f\f",
      components: [:speed, :distance],
      example: "1",
      scale: [100, 16],
      units: ["m/s", "m"]
    )

    field(9, :grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(10, :resistance, :uint8, comment: "Relative. 0 is none 254 is Max.", example: "1")
    field(11, :time_from_course, :sint32, example: "1", scale: [1000], units: ["s"])
    field(12, :cycle_length, :uint8, example: "1", scale: ~c"d", units: ["m"])
    field(13, :temperature, :sint8, example: "1", units: ["C"])

    field(17, :speed_1s, :uint8,
      array: true,
      comment: "Speed at 1s intervals. Timestamp field indicates time of last array element.",
      example: "5",
      scale: [16],
      units: ["m/s"]
    )

    field(18, :cycles, :uint8,
      accumulate: [true],
      bits: ~c"\b",
      components: [:total_cycles],
      example: "1",
      units: ["cycles"]
    )

    field(19, :total_cycles, :uint32, example: "1", units: ["cycles"])

    field(28, :compressed_accumulated_power, :uint16,
      accumulate: [true],
      bits: [16],
      components: [:accumulated_power],
      example: "1",
      units: ["watts"]
    )

    field(29, :accumulated_power, :uint32, example: "1", units: ["watts"])
    field(30, :left_right_balance, :left_right_balance, example: "1")
    field(31, :gps_accuracy, :uint8, example: "1", units: ["m"])
    field(32, :vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(33, :calories, :uint16, example: "1", units: ["kcal"])
    field(39, :vertical_oscillation, :uint16, example: "1", scale: ~c"\n", units: ["mm"])
    field(40, :stance_time_percent, :uint16, example: "1", scale: ~c"d", units: ["percent"])
    field(41, :stance_time, :uint16, example: "1", scale: ~c"\n", units: ["ms"])
    field(42, :activity_type, :activity_type, example: "1")
    field(43, :left_torque_effectiveness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(44, :right_torque_effectiveness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(45, :left_pedal_smoothness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(46, :right_pedal_smoothness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(47, :combined_pedal_smoothness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(48, :time128, :uint8, example: "1", scale: [128], units: ["s"])
    field(49, :stroke_type, :stroke_type, example: "1")
    field(50, :zone, :uint8, example: "1")
    field(51, :ball_speed, :uint16, example: "1", scale: ~c"d", units: ["m/s"])

    field(52, :cadence256, :uint16,
      comment: "Log cadence and fractional cadence for backwards compatability",
      example: "1",
      scale: [256],
      units: ["rpm"]
    )

    field(53, :fractional_cadence, :uint8, example: "1", scale: [128], units: ["rpm"])

    field(54, :total_hemoglobin_conc, :uint16,
      comment: "Total saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(55, :total_hemoglobin_conc_min, :uint16,
      comment: "Min saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(56, :total_hemoglobin_conc_max, :uint16,
      comment: "Max saturated and unsaturated hemoglobin",
      example: "1",
      scale: ~c"d",
      units: ["g/dL"]
    )

    field(57, :saturated_hemoglobin_percent, :uint16,
      comment: "Percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(58, :saturated_hemoglobin_percent_min, :uint16,
      comment: "Min percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(59, :saturated_hemoglobin_percent_max, :uint16,
      comment: "Max percentage of hemoglobin saturated with oxygen",
      example: "1",
      scale: ~c"\n",
      units: ["%"]
    )

    field(62, :device_index, :device_index, example: "1")
    field(67, :left_pco, :sint8, comment: "Left platform center offset", units: ["mm"])
    field(68, :right_pco, :sint8, comment: "Right platform center offset", units: ["mm"])

    field(69, :left_power_phase, :uint8,
      array: true,
      comment: "Left power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(70, :left_power_phase_peak, :uint8,
      array: true,
      comment: "Left power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(71, :right_power_phase, :uint8,
      array: true,
      comment: "Right power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(72, :right_power_phase_peak, :uint8,
      array: true,
      comment: "Right power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(73, :enhanced_speed, :uint32, example: "1", scale: [1000], units: ["m/s"])
    field(78, :enhanced_altitude, :uint32, example: "1", offset: [500], scale: [5], units: ["m"])

    field(81, :battery_soc, :uint8,
      comment: "lev battery state of charge",
      scale: [2],
      units: ["percent"]
    )

    field(82, :motor_power, :uint16, comment: "lev motor power", units: ["watts"])
    field(83, :vertical_ratio, :uint16, scale: ~c"d", units: ["percent"])
    field(84, :stance_time_balance, :uint16, scale: ~c"d", units: ["percent"])
    field(85, :step_length, :uint16, scale: ~c"\n", units: ["mm"])

    field(87, :cycle_length16, :uint16,
      comment: "Supports larger cycle sizes needed for paddlesports. Max cycle size: 655.35",
      scale: ~c"d",
      units: ["m"]
    )

    field(91, :absolute_pressure, :uint32,
      comment: "Includes atmospheric pressure",
      units: ["Pa"]
    )

    field(92, :depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(93, :next_stop_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(94, :next_stop_time, :uint32, scale: [1], units: ["s"])
    field(95, :time_to_surface, :uint32, scale: [1], units: ["s"])
    field(96, :ndl_time, :uint32, scale: [1], units: ["s"])
    field(97, :cns_load, :uint8, units: ["percent"])
    field(98, :n2_load, :uint16, scale: [1], units: ["percent"])

    field(99, :respiration_rate, :uint8,
      bits: ~c"\b",
      components: [:enhanced_respiration_rate],
      scale: [1],
      units: ["s"]
    )

    field(108, :enhanced_respiration_rate, :uint16, scale: ~c"d", units: ["Breaths/min"])

    field(114, :grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes."
    )

    field(115, :flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals."
    )

    field(116, :current_stress, :uint16, comment: "Current Stress value", scale: ~c"d")
    field(117, :ebike_travel_range, :uint16, units: ["km"])
    field(118, :ebike_battery_level, :uint8, units: ["percent"])
    field(119, :ebike_assist_mode, :uint8, units: ["depends on sensor"])
    field(120, :ebike_assist_level_percent, :uint8, units: ["percent"])
    field(123, :air_time_remaining, :uint32, units: ["s"])

    field(124, :pressure_sac, :uint16,
      comment: "Pressure-based surface air consumption",
      scale: ~c"d",
      units: ["bar/min"]
    )

    field(125, :volume_sac, :uint16,
      comment: "Volumetric surface air consumption",
      scale: ~c"d",
      units: ["L/min"]
    )

    field(126, :rmv, :uint16,
      comment: "Respiratory minute volume",
      scale: ~c"d",
      units: ["L/min"]
    )

    field(127, :ascent_rate, :sint32, scale: [1000], units: ["m/s"])

    field(129, :po2, :uint8,
      comment: "Current partial pressure of oxygen",
      scale: ~c"d",
      units: ["percent"]
    )

    field(139, :core_temperature, :uint16, scale: ~c"d", units: ["C"])
  end

  message(:event) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :event, :event, example: "1")
    field(1, :event_type, :event_type, example: "1")
    field(2, :data16, :uint16, bits: [16], components: [:data], example: "1")

    field(3, :data, :uint32,
      example: "1",
      subfields: [
        %{
          bits: ~c"\b\b\b\b",
          comment:
            "The first byte is the radar_threat_level_max, the second byte is the radar_threat_count, third bytes is the average approach speed, and the 4th byte is the max approach speed",
          components: [
            :radar_threat_level_max,
            :radar_threat_count,
            :radar_threat_avg_approach_speed,
            :radar_threat_max_approach_speed
          ],
          name: :radar_threat_alert,
          ref_fields: [event: "radar_threat_alert"],
          scale: [1, 1, 10, 10],
          type: :uint32
        },
        %{
          name: :auto_activity_detect_duration,
          ref_fields: [event: "auto_activity_detect"],
          type: :uint16,
          units: ["min"]
        },
        %{name: :dive_alert, ref_fields: [event: "dive_alert"], type: :dive_alert},
        %{name: :comm_timeout, ref_fields: [event: "comm_timeout"], type: :comm_timeout_type},
        %{
          comment: "Indicates the rider position value.",
          name: :rider_position,
          ref_fields: [event: "rider_position_change"],
          type: :rider_position_type
        },
        %{
          bits: ~c"\b\b\b\b",
          components: [:rear_gear_num, :rear_gear, :front_gear_num, :front_gear],
          example: "1",
          name: :gear_change_data,
          ref_fields: [event: "front_gear_change", event: "rear_gear_change"],
          scale: [1, 1, 1, 1],
          type: :uint32
        },
        %{
          bits: [16, 16],
          components: [:score, :opponent_score],
          example: "1",
          name: :sport_point,
          ref_fields: [event: "sport_point"],
          scale: [1, 1],
          type: :uint32
        },
        %{
          example: "1",
          name: :fitness_equipment_state,
          ref_fields: [event: "fitness_equipment"],
          type: :fitness_equipment_state
        },
        %{
          example: "1",
          name: :calorie_duration_alert,
          ref_fields: [event: "calorie_duration_alert"],
          type: :uint32,
          units: ["calories"]
        },
        %{
          example: "1",
          name: :distance_duration_alert,
          ref_fields: [event: "distance_duration_alert"],
          scale: ~c"d",
          type: :uint32,
          units: ["m"]
        },
        %{
          example: "1",
          name: :time_duration_alert,
          ref_fields: [event: "time_duration_alert"],
          scale: [1000],
          type: :uint32,
          units: ["s"]
        },
        %{
          example: "1",
          name: :power_low_alert,
          ref_fields: [event: "power_low_alert"],
          type: :uint16,
          units: ["watts"]
        },
        %{
          example: "1",
          name: :power_high_alert,
          ref_fields: [event: "power_high_alert"],
          type: :uint16,
          units: ["watts"]
        },
        %{example: "1", name: :cad_low_alert, ref_fields: [event: "cad_low_alert"], type: :uint16, units: ["rpm"]},
        %{example: "1", name: :cad_high_alert, ref_fields: [event: "cad_high_alert"], type: :uint16, units: ["rpm"]},
        %{
          example: "1",
          name: :speed_low_alert,
          ref_fields: [event: "speed_low_alert"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        },
        %{
          example: "1",
          name: :speed_high_alert,
          ref_fields: [event: "speed_high_alert"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        },
        %{example: "1", name: :hr_low_alert, ref_fields: [event: "hr_low_alert"], type: :uint8, units: ["bpm"]},
        %{example: "1", name: :hr_high_alert, ref_fields: [event: "hr_high_alert"], type: :uint8, units: ["bpm"]},
        %{
          example: "1",
          name: :virtual_partner_speed,
          ref_fields: [event: "virtual_partner_pace"],
          scale: [1000],
          type: :uint16,
          units: ["m/s"]
        },
        %{
          example: "1",
          name: :battery_level,
          ref_fields: [event: "battery"],
          scale: [1000],
          type: :uint16,
          units: ["V"]
        },
        %{example: "1", name: :course_point_index, ref_fields: [event: "course_point"], type: :message_index},
        %{example: "1", name: :timer_trigger, ref_fields: [event: "timer"], type: :timer_trigger}
      ]
    )

    field(4, :event_group, :uint8, example: "1")

    field(7, :score, :uint16,
      comment: "Do not populate directly. Autogenerated by decoder for sport_point subfield components",
      example: "1"
    )

    field(8, :opponent_score, :uint16,
      comment: "Do not populate directly. Autogenerated by decoder for sport_point subfield components",
      example: "1"
    )

    field(9, :front_gear_num, :uint8z,
      comment:
        "Do not populate directly. Autogenerated by decoder for gear_change subfield components. Front gear number. 1 is innermost.",
      example: "1"
    )

    field(10, :front_gear, :uint8z,
      comment:
        "Do not populate directly. Autogenerated by decoder for gear_change subfield components. Number of front teeth.",
      example: "1"
    )

    field(11, :rear_gear_num, :uint8z,
      comment:
        "Do not populate directly. Autogenerated by decoder for gear_change subfield components. Rear gear number. 1 is innermost.",
      example: "1"
    )

    field(12, :rear_gear, :uint8z,
      comment:
        "Do not populate directly. Autogenerated by decoder for gear_change subfield components. Number of rear teeth.",
      example: "1"
    )

    field(13, :device_index, :device_index)

    field(14, :activity_type, :activity_type, comment: "Activity Type associated with an auto_activity_detect event")

    field(15, :start_timestamp, :date_time,
      comment: "Timestamp of when the event started",
      subfields: [
        %{
          comment: "Auto Activity Detect Start Timestamp.",
          name: :auto_activity_detect_start_timestamp,
          ref_fields: [event: "auto_activity_detect"],
          type: :date_time,
          units: ["s"]
        }
      ],
      units: ["s"]
    )

    field(21, :radar_threat_level_max, :radar_threat_level_type,
      comment: "Do not populate directly. Autogenerated by decoder for threat_alert subfield components.",
      example: "1"
    )

    field(22, :radar_threat_count, :uint8,
      comment: "Do not populate directly. Autogenerated by decoder for threat_alert subfield components.",
      example: "1"
    )

    field(23, :radar_threat_avg_approach_speed, :uint8,
      comment: "Do not populate directly. Autogenerated by decoder for radar_threat_alert subfield components",
      scale: ~c"\n",
      units: ["m/s"]
    )

    field(24, :radar_threat_max_approach_speed, :uint8,
      comment: "Do not populate directly. Autogenerated by decoder for radar_threat_alert subfield components",
      scale: ~c"\n",
      units: ["m/s"]
    )
  end

  message(:device_info) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :device_index, :device_index, example: "1")

    field(1, :device_type, :uint8,
      example: "1",
      subfields: [
        %{example: "1", name: :local_device_type, ref_fields: [source_type: "local"], type: :local_device_type},
        %{example: "1", name: :ant_device_type, ref_fields: [source_type: "ant"], type: :uint8},
        %{example: "1", name: :antplus_device_type, ref_fields: [source_type: "antplus"], type: :antplus_device_type},
        %{name: :ble_device_type, ref_fields: [source_type: "bluetooth_low_energy"], type: :ble_device_type}
      ]
    )

    field(2, :manufacturer, :manufacturer, example: "1")
    field(3, :serial_number, :uint32z, example: "1")

    field(4, :product, :uint16,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :garmin_product,
          ref_fields: [
            manufacturer: "garmin",
            manufacturer: "dynastream",
            manufacturer: "dynastream_oem",
            manufacturer: "tacx"
          ],
          type: :garmin_product
        },
        %{name: :favero_product, ref_fields: [manufacturer: "favero_electronics"], type: :favero_product}
      ]
    )

    field(5, :software_version, :uint16, example: "1", scale: ~c"d")
    field(6, :hardware_version, :uint8, example: "1")

    field(7, :cum_operating_time, :uint32,
      comment: "Reset by new battery or charge.",
      example: "1",
      units: ["s"]
    )

    field(10, :battery_voltage, :uint16, example: "1", scale: [256], units: ["V"])
    field(11, :battery_status, :battery_status, example: "1")

    field(18, :sensor_position, :body_location,
      comment: "Indicates the location of the sensor",
      example: "1"
    )

    field(19, :descriptor, :string,
      comment: "Used to describe the sensor or location",
      example: "1"
    )

    field(20, :ant_transmission_type, :uint8z, example: "1")
    field(21, :ant_device_number, :uint16z, example: "1")
    field(22, :ant_network, :ant_network, example: "1")
    field(25, :source_type, :source_type, example: "1")

    field(27, :product_name, :string,
      comment: "Optional free form string to indicate the devices name or model",
      example: "20"
    )

    field(32, :battery_level, :uint8, units: ["%"])
  end

  message(:device_aux_battery_info) do
    field(253, :timestamp, :date_time, example: "1")
    field(0, :device_index, :device_index, example: "1")
    field(1, :battery_voltage, :uint16, example: "1", scale: [256], units: ["V"])
    field(2, :battery_status, :battery_status, example: "1")
    field(3, :battery_identifier, :uint8, example: "1")
  end

  message(:training_file) do
    field(253, :timestamp, :date_time, example: "1")
    field(0, :type, :file, example: "1")
    field(1, :manufacturer, :manufacturer, example: "1")

    field(2, :product, :uint16,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :garmin_product,
          ref_fields: [
            manufacturer: "garmin",
            manufacturer: "dynastream",
            manufacturer: "dynastream_oem",
            manufacturer: "tacx"
          ],
          type: :garmin_product
        },
        %{name: :favero_product, ref_fields: [manufacturer: "favero_electronics"], type: :favero_product}
      ]
    )

    field(3, :serial_number, :uint32z, example: "1")
    field(4, :time_created, :date_time, example: "1")
  end

  message(:weather_conditions) do
    field(253, :timestamp, :date_time,
      comment: "time of update for current conditions, else forecast time",
      example: "1"
    )

    field(0, :weather_report, :weather_report, comment: "Current or forecast", example: "1")
    field(1, :temperature, :sint8, example: "1", units: ["C"])

    field(2, :condition, :weather_status,
      comment: "Corresponds to GSC Response weatherIcon field",
      example: "1"
    )

    field(3, :wind_direction, :uint16, example: "1", units: ["degrees"])
    field(4, :wind_speed, :uint16, example: "1", scale: [1000], units: ["m/s"])
    field(5, :precipitation_probability, :uint8, comment: "range 0-100", example: "1")

    field(6, :temperature_feels_like, :sint8,
      comment: "Heat Index if GCS heatIdx above or equal to 90F or wind chill if GCS windChill below or equal to 32F",
      example: "1",
      units: ["C"]
    )

    field(7, :relative_humidity, :uint8, example: "1")

    field(8, :location, :string,
      comment: "string corresponding to GCS response location string",
      example: "64"
    )

    field(9, :observed_at_time, :date_time, example: "1")
    field(10, :observed_location_lat, :sint32, example: "1", units: ["semicircles"])
    field(11, :observed_location_long, :sint32, example: "1", units: ["semicircles"])
    field(12, :day_of_week, :day_of_week, example: "1")
    field(13, :high_temperature, :sint8, example: "1", units: ["C"])
    field(14, :low_temperature, :sint8, example: "1", units: ["C"])
  end

  message(:weather_alert) do
    field(253, :timestamp, :date_time, example: "1")

    field(0, :report_id, :string,
      comment: "Unique identifier from GCS report ID string, length is 12",
      example: "12"
    )

    field(1, :issue_time, :date_time, comment: "Time alert was issued", example: "1")
    field(2, :expire_time, :date_time, comment: "Time alert expires", example: "1")

    field(3, :severity, :weather_severity,
      comment: "Warning, Watch, Advisory, Statement",
      example: "1"
    )

    field(4, :type, :weather_severe_type,
      comment: "Tornado, Severe Thunderstorm, etc.",
      example: "1"
    )
  end

  message(:gps_metadata) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp.",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])
    field(1, :position_lat, :sint32, units: ["semicircles"])
    field(2, :position_long, :sint32, units: ["semicircles"])
    field(3, :enhanced_altitude, :uint32, offset: [500], scale: [5], units: ["m"])
    field(4, :enhanced_speed, :uint32, scale: [1000], units: ["m/s"])
    field(5, :heading, :uint16, scale: ~c"d", units: ["degrees"])

    field(6, :utc_timestamp, :date_time,
      comment:
        "Used to correlate UTC to system time if the timestamp of the message is in system time. This UTC time is derived from the GPS data.",
      units: ["s"]
    )

    field(7, :velocity, :sint16,
      array: 3,
      comment: "velocity[0] is lon velocity. Velocity[1] is lat velocity. Velocity[2] is altitude velocity.",
      scale: ~c"d",
      units: ["m/s"]
    )
  end

  message(:camera_event) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp.",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])
    field(1, :camera_event_type, :camera_event_type)
    field(2, :camera_file_uuid, :string)
    field(3, :camera_orientation, :camera_orientation_type)
  end

  message(:gyroscope_data) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])

    field(1, :sample_time_offset, :uint16,
      array: true,
      comment:
        "Each time in the array describes the time at which the gyro sample with the corrosponding index was taken. Limited to 30 samples in each message. The samples may span across seconds. Array size must match the number of samples in gyro_x and gyro_y and gyro_z",
      units: ["ms"]
    )

    field(2, :gyro_x, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(3, :gyro_y, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(4, :gyro_z, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(5, :calibrated_gyro_x, :float32,
      array: true,
      comment: "Calibrated gyro reading",
      units: ["deg/s"]
    )

    field(6, :calibrated_gyro_y, :float32,
      array: true,
      comment: "Calibrated gyro reading",
      units: ["deg/s"]
    )

    field(7, :calibrated_gyro_z, :float32,
      array: true,
      comment: "Calibrated gyro reading",
      units: ["deg/s"]
    )
  end

  message(:accelerometer_data) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])

    field(1, :sample_time_offset, :uint16,
      array: true,
      comment:
        "Each time in the array describes the time at which the accelerometer sample with the corrosponding index was taken. Limited to 30 samples in each message. The samples may span across seconds. Array size must match the number of samples in accel_x and accel_y and accel_z",
      units: ["ms"]
    )

    field(2, :accel_x, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(3, :accel_y, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(4, :accel_z, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(5, :calibrated_accel_x, :float32,
      array: true,
      comment: "Calibrated accel reading",
      units: ["g"]
    )

    field(6, :calibrated_accel_y, :float32,
      array: true,
      comment: "Calibrated accel reading",
      units: ["g"]
    )

    field(7, :calibrated_accel_z, :float32,
      array: true,
      comment: "Calibrated accel reading",
      units: ["g"]
    )

    field(8, :compressed_calibrated_accel_x, :sint16,
      array: true,
      comment: "Calibrated accel reading",
      units: ["mG"]
    )

    field(9, :compressed_calibrated_accel_y, :sint16,
      array: true,
      comment: "Calibrated accel reading",
      units: ["mG"]
    )

    field(10, :compressed_calibrated_accel_z, :sint16,
      array: true,
      comment: "Calibrated accel reading",
      units: ["mG"]
    )
  end

  message(:magnetometer_data) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])

    field(1, :sample_time_offset, :uint16,
      array: true,
      comment:
        "Each time in the array describes the time at which the compass sample with the corrosponding index was taken. Limited to 30 samples in each message. The samples may span across seconds. Array size must match the number of samples in cmps_x and cmps_y and cmps_z",
      units: ["ms"]
    )

    field(2, :mag_x, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(3, :mag_y, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(4, :mag_z, :uint16,
      array: true,
      comment:
        "These are the raw ADC reading. Maximum number of samples is 30 in each message. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["counts"]
    )

    field(5, :calibrated_mag_x, :float32,
      array: true,
      comment: "Calibrated Magnetometer reading",
      units: ["G"]
    )

    field(6, :calibrated_mag_y, :float32,
      array: true,
      comment: "Calibrated Magnetometer reading",
      units: ["G"]
    )

    field(7, :calibrated_mag_z, :float32,
      array: true,
      comment: "Calibrated Magnetometer reading",
      units: ["G"]
    )
  end

  message(:barometer_data) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])

    field(1, :sample_time_offset, :uint16,
      array: true,
      comment:
        "Each time in the array describes the time at which the barometer sample with the corrosponding index was taken. The samples may span across seconds. Array size must match the number of samples in baro_cal",
      units: ["ms"]
    )

    field(2, :baro_pres, :uint32,
      array: true,
      comment:
        "These are the raw ADC reading. The samples may span across seconds. A conversion will need to be done on this data once read.",
      units: ["Pa"]
    )
  end

  message(:three_d_sensor_calibration) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :sensor_type, :sensor_type, comment: "Indicates which sensor the calibration is for")

    field(1, :calibration_factor, :uint32,
      comment: "Calibration factor used to convert from raw ADC value to degrees, g, etc.",
      subfields: [
        %{
          comment: "Gyro calibration factor",
          name: :gyro_cal_factor,
          ref_fields: [sensor_type: "gyroscope"],
          type: :uint32,
          units: ["deg/s"]
        },
        %{
          comment: "Accelerometer calibration factor",
          name: :accel_cal_factor,
          ref_fields: [sensor_type: "accelerometer"],
          type: :uint32,
          units: ["g"]
        }
      ]
    )

    field(2, :calibration_divisor, :uint32,
      comment: "Calibration factor divisor",
      units: ["counts"]
    )

    field(3, :level_shift, :uint32, comment: "Level shift value used to shift the ADC value back into range")

    field(4, :offset_cal, :sint32,
      array: 3,
      comment: "Internal calibration factors, one for each: xy, yx, zx"
    )

    field(5, :orientation_matrix, :sint32,
      array: 9,
      comment: "3 x 3 rotation matrix (row major)",
      scale: [65535]
    )
  end

  message(:one_d_sensor_calibration) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :sensor_type, :sensor_type, comment: "Indicates which sensor the calibration is for")

    field(1, :calibration_factor, :uint32,
      comment: "Calibration factor used to convert from raw ADC value to degrees, g, etc.",
      subfields: [
        %{
          comment: "Barometer calibration factor",
          name: :baro_cal_factor,
          ref_fields: [sensor_type: "barometer"],
          type: :uint32,
          units: ["Pa"]
        }
      ]
    )

    field(2, :calibration_divisor, :uint32,
      comment: "Calibration factor divisor",
      units: ["counts"]
    )

    field(3, :level_shift, :uint32, comment: "Level shift value used to shift the ADC value back into range")

    field(4, :offset_cal, :sint32, comment: "Internal Calibration factor")
  end

  message(:video_frame) do
    field(253, :timestamp, :date_time,
      comment: "Whole second part of the timestamp",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16, comment: "Millisecond part of the timestamp.", units: ["ms"])

    field(1, :frame_number, :uint32, comment: "Number of the frame that the timestamp and timestamp_ms correlate to")
  end

  message(:obdii_data) do
    field(253, :timestamp, :date_time, comment: "Timestamp message was output", units: ["s"])

    field(0, :timestamp_ms, :uint16,
      comment: "Fractional part of timestamp, added to timestamp",
      units: ["ms"]
    )

    field(1, :time_offset, :uint16,
      array: true,
      comment: "Offset of PID reading [i] from start_timestamp+start_timestamp_ms. Readings may span accross seconds.",
      units: ["ms"]
    )

    field(2, :pid, :byte, comment: "Parameter ID")
    field(3, :raw_data, :byte, array: true, comment: "Raw parameter data")

    field(4, :pid_data_size, :uint8,
      array: true,
      comment: "Optional, data size of PID[i]. If not specified refer to SAE J1979."
    )

    field(5, :system_time, :uint32,
      array: true,
      comment:
        "System time associated with sample expressed in ms, can be used instead of time_offset. There will be a system_time value for each raw_data element. For multibyte pids the system_time is repeated."
    )

    field(6, :start_timestamp, :date_time,
      comment:
        "Timestamp of first sample recorded in the message. Used with time_offset to generate time of each sample"
    )

    field(7, :start_timestamp_ms, :uint16,
      comment: "Fractional part of start_timestamp",
      units: ["ms"]
    )
  end

  message(:nmea_sentence) do
    field(253, :timestamp, :date_time,
      comment: "Timestamp message was output",
      example: "1",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16,
      comment: "Fractional part of timestamp, added to timestamp",
      example: "1",
      units: ["ms"]
    )

    field(1, :sentence, :string, comment: "NMEA sentence", example: "83")
  end

  message(:aviation_attitude) do
    field(253, :timestamp, :date_time,
      comment: "Timestamp message was output",
      example: "1",
      units: ["s"]
    )

    field(0, :timestamp_ms, :uint16,
      comment: "Fractional part of timestamp, added to timestamp",
      example: "1",
      units: ["ms"]
    )

    field(1, :system_time, :uint32,
      array: true,
      comment: "System time associated with sample expressed in ms.",
      example: "1",
      units: ["ms"]
    )

    field(2, :pitch, :sint16,
      array: true,
      comment: "Range -PI/2 to +PI/2",
      example: "1",
      scale: [10430.38],
      units: ["radians"]
    )

    field(3, :roll, :sint16,
      array: true,
      comment: "Range -PI to +PI",
      example: "1",
      scale: [10430.38],
      units: ["radians"]
    )

    field(4, :accel_lateral, :sint16,
      array: true,
      comment: "Range -78.4 to +78.4 (-8 Gs to 8 Gs)",
      example: "1",
      scale: ~c"d",
      units: ["m/s^2"]
    )

    field(5, :accel_normal, :sint16,
      array: true,
      comment: "Range -78.4 to +78.4 (-8 Gs to 8 Gs)",
      example: "1",
      scale: ~c"d",
      units: ["m/s^2"]
    )

    field(6, :turn_rate, :sint16,
      array: true,
      comment: "Range -8.727 to +8.727 (-500 degs/sec to +500 degs/sec)",
      example: "1",
      scale: [1024],
      units: ["radians/second"]
    )

    field(7, :stage, :attitude_stage, array: true, example: "1")

    field(8, :attitude_stage_complete, :uint8,
      array: true,
      comment:
        "The percent complete of the current attitude stage. Set to 0 for attitude stages 0, 1 and 2 and to 100 for attitude stage 3 by AHRS modules that do not support it. Range - 100",
      example: "1",
      units: ["%"]
    )

    field(9, :track, :uint16,
      array: true,
      comment: "Track Angle/Heading Range 0 - 2pi",
      example: "1",
      scale: [10430.38],
      units: ["radians"]
    )

    field(10, :validity, :attitude_validity, array: true, example: "1")
  end

  message(:video) do
    field(0, :url, :string)
    field(1, :hosting_provider, :string)
    field(2, :duration, :uint32, comment: "Playback time of video", units: ["ms"])
  end

  message(:video_title) do
    field(254, :message_index, :message_index,
      comment: "Long titles will be split into multiple parts",
      example: "1"
    )

    field(0, :message_count, :uint16, comment: "Total number of title parts", example: "1")
    field(1, :text, :string, example: "80")
  end

  message(:video_description) do
    field(254, :message_index, :message_index,
      comment: "Long descriptions will be split into multiple parts",
      example: "1"
    )

    field(0, :message_count, :uint16, comment: "Total number of description parts", example: "1")
    field(1, :text, :string, example: "250")
  end

  message(:video_clip) do
    field(0, :clip_number, :uint16)
    field(1, :start_timestamp, :date_time)
    field(2, :start_timestamp_ms, :uint16)
    field(3, :end_timestamp, :date_time)
    field(4, :end_timestamp_ms, :uint16)
    field(6, :clip_start, :uint32, comment: "Start of clip in video time", units: ["ms"])
    field(7, :clip_end, :uint32, comment: "End of clip in video time", units: ["ms"])
  end

  message(:set) do
    field(254, :timestamp, :date_time, comment: "Timestamp of the set")
    field(0, :duration, :uint32, scale: [1000], units: ["s"])
    field(3, :repetitions, :uint16, comment: "# of repitions of the movement")

    field(4, :weight, :uint16,
      comment: "Amount of weight applied for the set",
      scale: [16],
      units: ["kg"]
    )

    field(5, :set_type, :set_type)
    field(6, :start_time, :date_time, comment: "Start time of the set")
    field(7, :category, :exercise_category, array: true)

    field(8, :category_subtype, :uint16,
      array: true,
      comment: "Based on the associated category, see [category]_exercise_names"
    )

    field(9, :weight_display_unit, :fit_base_unit, example: "1")
    field(10, :message_index, :message_index)
    field(11, :wkt_step_index, :message_index)
  end

  message(:jump) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :distance, :float32, units: ["m"])
    field(1, :height, :float32, units: ["m"])
    field(2, :rotations, :uint8)
    field(3, :hang_time, :float32, units: ["s"])

    field(4, :score, :float32, comment: "A score for a jump calculated based on hang time, rotations, and distance.")

    field(5, :position_lat, :sint32, units: ["semicircles"])
    field(6, :position_long, :sint32, units: ["semicircles"])

    field(7, :speed, :uint16,
      bits: [16],
      components: [:enhanced_speed],
      scale: [1000],
      units: ["m/s"]
    )

    field(8, :enhanced_speed, :uint32, scale: [1000], units: ["m/s"])
  end

  message(:split) do
    field(254, :message_index, :message_index)
    field(0, :split_type, :split_type)
    field(1, :total_elapsed_time, :uint32, scale: [1000], units: ["s"])
    field(2, :total_timer_time, :uint32, scale: [1000], units: ["s"])
    field(3, :total_distance, :uint32, scale: ~c"d", units: ["m"])
    field(4, :avg_speed, :uint32, scale: [1000], units: ["m/s"])
    field(9, :start_time, :date_time)
    field(13, :total_ascent, :uint16, units: ["m"])
    field(14, :total_descent, :uint16, units: ["m"])
    field(21, :start_position_lat, :sint32, units: ["semicircles"])
    field(22, :start_position_long, :sint32, units: ["semicircles"])
    field(23, :end_position_lat, :sint32, units: ["semicircles"])
    field(24, :end_position_long, :sint32, units: ["semicircles"])
    field(25, :max_speed, :uint32, scale: [1000], units: ["m/s"])
    field(26, :avg_vert_speed, :sint32, scale: [1000], units: ["m/s"])
    field(27, :end_time, :date_time)
    field(28, :total_calories, :uint32, units: ["kcal"])
    field(74, :start_elevation, :uint32, offset: [500], scale: [5], units: ["m"])
    field(110, :total_moving_time, :uint32, scale: [1000], units: ["s"])
  end

  message(:split_summary) do
    field(254, :message_index, :message_index)
    field(0, :split_type, :split_type)
    field(3, :num_splits, :uint16)
    field(4, :total_timer_time, :uint32, scale: [1000], units: ["s"])
    field(5, :total_distance, :uint32, scale: ~c"d", units: ["m"])
    field(6, :avg_speed, :uint32, scale: [1000], units: ["m/s"])
    field(7, :max_speed, :uint32, scale: [1000], units: ["m/s"])
    field(8, :total_ascent, :uint16, units: ["m"])
    field(9, :total_descent, :uint16, units: ["m"])
    field(10, :avg_heart_rate, :uint8, units: ["bpm"])
    field(11, :max_heart_rate, :uint8, units: ["bpm"])
    field(12, :avg_vert_speed, :sint32, scale: [1000], units: ["m/s"])
    field(13, :total_calories, :uint32, units: ["kcal"])
    field(77, :total_moving_time, :uint32, scale: [1000], units: ["s"])
  end

  message(:climb_pro) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :position_lat, :sint32, units: ["semicircles"])
    field(1, :position_long, :sint32, units: ["semicircles"])
    field(2, :climb_pro_event, :climb_pro_event)
    field(3, :climb_number, :uint16)
    field(4, :climb_category, :uint8)
    field(5, :current_dist, :float32, units: ["m"])
  end

  message(:field_description) do
    field(0, :developer_data_index, :uint8, example: "1")
    field(1, :field_definition_number, :uint8, example: "1")
    field(2, :fit_base_type_id, :fit_base_type, example: "1")
    field(3, :field_name, :string, array: true, example: "64")
    field(4, :array, :uint8, example: "0")
    field(5, :components, :string, example: "0")
    field(6, :scale, :uint8, example: "1")
    field(7, :offset, :sint8, example: "1")
    field(8, :units, :string, array: true, example: "16")
    field(9, :bits, :string, example: "0")
    field(10, :accumulate, :string, example: "0")
    field(13, :fit_base_unit_id, :fit_base_unit, example: "1")
    field(14, :native_mesg_num, :mesg_num, example: "1")
    field(15, :native_field_num, :uint8, example: "1")
  end

  message(:developer_data_id) do
    field(0, :developer_id, :byte, array: true, example: "16")
    field(1, :application_id, :byte, array: true, example: "16")
    field(2, :manufacturer_id, :manufacturer, example: "1")
    field(3, :developer_data_index, :uint8, example: "1")
    field(4, :application_version, :uint32, example: "1")
  end

  message(:course) do
    field(4, :sport, :sport, example: "1")
    field(5, :name, :string, example: "16")
    field(6, :capabilities, :course_capabilities, example: "1")
    field(7, :sub_sport, :sub_sport, example: "1")
  end

  message(:course_point) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :timestamp, :date_time, example: "1")
    field(2, :position_lat, :sint32, example: "1", units: ["semicircles"])
    field(3, :position_long, :sint32, example: "1", units: ["semicircles"])
    field(4, :distance, :uint32, example: "1", scale: ~c"d", units: ["m"])
    field(5, :type, :course_point, example: "1")
    field(6, :name, :string, example: "16")
    field(8, :favorite, :bool, example: "1")
  end

  message(:segment_id) do
    field(0, :name, :string, comment: "Friendly name assigned to segment", example: "1")
    field(1, :uuid, :string, comment: "UUID of the segment", example: "1")
    field(2, :sport, :sport, comment: "Sport associated with the segment", example: "1")
    field(3, :enabled, :bool, comment: "Segment enabled for evaluation", example: "1")

    field(4, :user_profile_primary_key, :uint32,
      comment: "Primary key of the user that created the segment",
      example: "1"
    )

    field(5, :device_id, :uint32,
      comment: "ID of the device that created the segment",
      example: "1"
    )

    field(6, :default_race_leader, :uint8,
      comment: "Index for the Leader Board entry selected as the default race participant",
      example: "1"
    )

    field(7, :delete_status, :segment_delete_status,
      comment: "Indicates if any segments should be deleted",
      example: "1"
    )

    field(8, :selection_type, :segment_selection_type,
      comment: "Indicates how the segment was selected to be sent to the device",
      example: "1"
    )
  end

  message(:segment_leaderboard_entry) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :name, :string, comment: "Friendly name assigned to leader", example: "1")
    field(1, :type, :segment_leaderboard_type, comment: "Leader classification", example: "1")
    field(2, :group_primary_key, :uint32, comment: "Primary user ID of this leader", example: "1")

    field(3, :activity_id, :uint32,
      comment: "ID of the activity associated with this leader time",
      example: "1"
    )

    field(4, :segment_time, :uint32,
      comment: "Segment Time (includes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(5, :activity_id_string, :string,
      comment: "String version of the activity_id. 21 characters long, express in decimal"
    )
  end

  message(:segment_point) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :position_lat, :sint32, example: "1", units: ["semicircles"])
    field(2, :position_long, :sint32, example: "1", units: ["semicircles"])

    field(3, :distance, :uint32,
      comment: "Accumulated distance along the segment at the described point",
      example: "1",
      scale: ~c"d",
      units: ["m"]
    )

    field(4, :altitude, :uint16,
      bits: [16],
      comment: "Accumulated altitude along the segment at the described point",
      components: [:enhanced_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(5, :leader_time, :uint32,
      array: true,
      comment:
        "Accumualted time each leader board member required to reach the described point. This value is zero for all leader board members at the starting point of the segment.",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(6, :enhanced_altitude, :uint32,
      comment: "Accumulated altitude along the segment at the described point",
      offset: [500],
      scale: [5],
      units: ["m"]
    )
  end

  message(:segment_lap) do
    field(254, :message_index, :message_index, example: "1")
    field(253, :timestamp, :date_time, comment: "Lap end time.", example: "1", units: ["s"])
    field(0, :event, :event, example: "1")
    field(1, :event_type, :event_type, example: "1")
    field(2, :start_time, :date_time, example: "1")
    field(3, :start_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(4, :start_position_long, :sint32, example: "1", units: ["semicircles"])
    field(5, :end_position_lat, :sint32, example: "1", units: ["semicircles"])
    field(6, :end_position_long, :sint32, example: "1", units: ["semicircles"])

    field(7, :total_elapsed_time, :uint32,
      comment: "Time (includes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(8, :total_timer_time, :uint32,
      comment: "Timer Time (excludes pauses)",
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(9, :total_distance, :uint32, example: "1", scale: ~c"d", units: ["m"])

    field(10, :total_cycles, :uint32,
      example: "1",
      subfields: [
        %{example: "1", name: :total_strokes, ref_fields: [sport: "cycling"], type: :uint32, units: ["strokes"]}
      ],
      units: ["cycles"]
    )

    field(11, :total_calories, :uint16, example: "1", units: ["kcal"])
    field(12, :total_fat_calories, :uint16, comment: "If New Leaf", example: "1", units: ["kcal"])
    field(13, :avg_speed, :uint16, example: "1", scale: [1000], units: ["m/s"])
    field(14, :max_speed, :uint16, example: "1", scale: [1000], units: ["m/s"])
    field(15, :avg_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(16, :max_heart_rate, :uint8, example: "1", units: ["bpm"])

    field(17, :avg_cadence, :uint8,
      comment: "total_cycles / total_timer_time if non_zero_avg_cadence otherwise total_cycles / total_elapsed_time",
      example: "1",
      units: ["rpm"]
    )

    field(18, :max_cadence, :uint8, example: "1", units: ["rpm"])

    field(19, :avg_power, :uint16,
      comment: "total_power / total_timer_time if non_zero_avg_power otherwise total_power / total_elapsed_time",
      example: "1",
      units: ["watts"]
    )

    field(20, :max_power, :uint16, example: "1", units: ["watts"])
    field(21, :total_ascent, :uint16, example: "1", units: ["m"])
    field(22, :total_descent, :uint16, example: "1", units: ["m"])
    field(23, :sport, :sport, example: "1")
    field(24, :event_group, :uint8, example: "1")

    field(25, :nec_lat, :sint32,
      comment: "North east corner latitude.",
      example: "1",
      units: ["semicircles"]
    )

    field(26, :nec_long, :sint32,
      comment: "North east corner longitude.",
      example: "1",
      units: ["semicircles"]
    )

    field(27, :swc_lat, :sint32,
      comment: "South west corner latitude.",
      example: "1",
      units: ["semicircles"]
    )

    field(28, :swc_long, :sint32,
      comment: "South west corner latitude.",
      example: "1",
      units: ["semicircles"]
    )

    field(29, :name, :string, example: "16")
    field(30, :normalized_power, :uint16, example: "1", units: ["watts"])
    field(31, :left_right_balance, :left_right_balance_100, example: "1")
    field(32, :sub_sport, :sub_sport, example: "1")
    field(33, :total_work, :uint32, example: "1", units: ["J"])

    field(34, :avg_altitude, :uint16,
      bits: [16],
      components: [:enhanced_avg_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(35, :max_altitude, :uint16,
      bits: [16],
      components: [:enhanced_max_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(36, :gps_accuracy, :uint8, example: "1", units: ["m"])
    field(37, :avg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(38, :avg_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(39, :avg_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(40, :max_pos_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(41, :max_neg_grade, :sint16, example: "1", scale: ~c"d", units: ["%"])
    field(42, :avg_temperature, :sint8, example: "1", units: ["C"])
    field(43, :max_temperature, :sint8, example: "1", units: ["C"])
    field(44, :total_moving_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(45, :avg_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(46, :avg_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(47, :max_pos_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(48, :max_neg_vertical_speed, :sint16, example: "1", scale: [1000], units: ["m/s"])
    field(49, :time_in_hr_zone, :uint32, array: true, example: "1", scale: [1000], units: ["s"])

    field(50, :time_in_speed_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(51, :time_in_cadence_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(52, :time_in_power_zone, :uint32,
      array: true,
      example: "1",
      scale: [1000],
      units: ["s"]
    )

    field(53, :repetition_num, :uint16, example: "1")

    field(54, :min_altitude, :uint16,
      bits: [16],
      components: [:enhanced_min_altitude],
      example: "1",
      offset: [500],
      scale: [5],
      units: ["m"]
    )

    field(55, :min_heart_rate, :uint8, example: "1", units: ["bpm"])
    field(56, :active_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(57, :wkt_step_index, :message_index, example: "1")
    field(58, :sport_event, :sport_event, example: "1")

    field(59, :avg_left_torque_effectiveness, :uint8,
      example: "1",
      scale: [2],
      units: ["percent"]
    )

    field(60, :avg_right_torque_effectiveness, :uint8,
      example: "1",
      scale: [2],
      units: ["percent"]
    )

    field(61, :avg_left_pedal_smoothness, :uint8, example: "1", scale: [2], units: ["percent"])
    field(62, :avg_right_pedal_smoothness, :uint8, example: "1", scale: [2], units: ["percent"])

    field(63, :avg_combined_pedal_smoothness, :uint8,
      example: "1",
      scale: [2],
      units: ["percent"]
    )

    field(64, :status, :segment_lap_status, example: "1")
    field(65, :uuid, :string, example: "33")

    field(66, :avg_fractional_cadence, :uint8,
      comment: "fractional part of the avg_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(67, :max_fractional_cadence, :uint8,
      comment: "fractional part of the max_cadence",
      example: "1",
      scale: [128],
      units: ["rpm"]
    )

    field(68, :total_fractional_cycles, :uint8,
      comment: "fractional part of the total_cycles",
      example: "1",
      scale: [128],
      units: ["cycles"]
    )

    field(69, :front_gear_shift_count, :uint16, example: "1")
    field(70, :rear_gear_shift_count, :uint16, example: "1")

    field(71, :time_standing, :uint32,
      comment: "Total time spent in the standing position",
      scale: [1000],
      units: ["s"]
    )

    field(72, :stand_count, :uint16, comment: "Number of transitions to the standing state")

    field(73, :avg_left_pco, :sint8,
      comment: "Average left platform center offset",
      units: ["mm"]
    )

    field(74, :avg_right_pco, :sint8,
      comment: "Average right platform center offset",
      units: ["mm"]
    )

    field(75, :avg_left_power_phase, :uint8,
      array: true,
      comment: "Average left power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(76, :avg_left_power_phase_peak, :uint8,
      array: true,
      comment: "Average left power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(77, :avg_right_power_phase, :uint8,
      array: true,
      comment: "Average right power phase angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(78, :avg_right_power_phase_peak, :uint8,
      array: true,
      comment: "Average right power phase peak angles. Data value indexes defined by power_phase_type.",
      scale: [0.7111111],
      units: ["degrees"]
    )

    field(79, :avg_power_position, :uint16,
      array: true,
      comment: "Average power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(80, :max_power_position, :uint16,
      array: true,
      comment: "Maximum power by position. Data value indexes defined by rider_position_type.",
      units: ["watts"]
    )

    field(81, :avg_cadence_position, :uint8,
      array: true,
      comment: "Average cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(82, :max_cadence_position, :uint8,
      array: true,
      comment: "Maximum cadence by position. Data value indexes defined by rider_position_type.",
      units: ["rpm"]
    )

    field(83, :manufacturer, :manufacturer, comment: "Manufacturer that produced the segment")

    field(84, :total_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(85, :total_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(86, :avg_grit, :float32,
      comment:
        "The grit score estimates how challenging a route could be for a cyclist in terms of time spent going over sharp turns or large grade slopes.",
      units: ["kGrit"]
    )

    field(87, :avg_flow, :float32,
      comment:
        "The flow score estimates how long distance wise a cyclist deaccelerates over intervals where deacceleration is unnecessary such as smooth turns or small grade angle intervals.",
      units: ["Flow"]
    )

    field(89, :total_fractional_ascent, :uint8,
      comment: "fractional part of total_ascent",
      scale: ~c"d",
      units: ["m"]
    )

    field(90, :total_fractional_descent, :uint8,
      comment: "fractional part of total_descent",
      scale: ~c"d",
      units: ["m"]
    )

    field(91, :enhanced_avg_altitude, :uint32, offset: [500], scale: [5], units: ["m"])
    field(92, :enhanced_max_altitude, :uint32, offset: [500], scale: [5], units: ["m"])
    field(93, :enhanced_min_altitude, :uint32, offset: [500], scale: [5], units: ["m"])
  end

  message(:segment_file) do
    field(254, :message_index, :message_index, example: "1")
    field(1, :file_uuid, :string, comment: "UUID of the segment file", example: "1")
    field(3, :enabled, :bool, comment: "Enabled state of the segment file", example: "1")

    field(4, :user_profile_primary_key, :uint32,
      comment: "Primary key of the user that created the segment file",
      example: "1"
    )

    field(7, :leader_type, :segment_leaderboard_type,
      array: true,
      comment: "Leader type of each leader in the segment file",
      example: "1"
    )

    field(8, :leader_group_primary_key, :uint32,
      array: true,
      comment: "Group primary key of each leader in the segment file",
      example: "1"
    )

    field(9, :leader_activity_id, :uint32,
      array: true,
      comment: "Activity ID of each leader in the segment file",
      example: "1"
    )

    field(10, :leader_activity_id_string, :string,
      array: true,
      comment:
        "String version of the activity ID of each leader in the segment file. 21 characters long for each ID, express in decimal"
    )

    field(11, :default_race_leader, :uint8,
      comment: "Index for the Leader Board entry selected as the default race participant"
    )
  end

  message(:workout) do
    field(254, :message_index, :message_index, example: "1")
    field(4, :sport, :sport, example: "1")
    field(5, :capabilities, :workout_capabilities, example: "1")
    field(6, :num_valid_steps, :uint16, comment: "number of valid steps", example: "1")
    field(8, :wkt_name, :string, example: "16")
    field(11, :sub_sport, :sub_sport, example: "1")
    field(14, :pool_length, :uint16, example: "1", scale: ~c"d", units: ["m"])
    field(15, :pool_length_unit, :display_measure, example: "1")
  end

  message(:workout_session) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :sport, :sport, example: "1")
    field(1, :sub_sport, :sub_sport, example: "1")
    field(2, :num_valid_steps, :uint16, example: "1")
    field(3, :first_step_index, :uint16, example: "1")
    field(4, :pool_length, :uint16, example: "1", scale: ~c"d", units: ["m"])
    field(5, :pool_length_unit, :display_measure, example: "1")
  end

  message(:workout_step) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :wkt_step_name, :string, example: "16")
    field(1, :duration_type, :wkt_step_duration, example: "1")

    field(2, :duration_value, :uint32,
      example: "1",
      subfields: [
        %{example: "1", name: :duration_reps, ref_fields: [duration_type: "reps"], type: :uint32},
        %{
          example: "1",
          name: :duration_power,
          ref_fields: [duration_type: "power_less_than", duration_type: "power_greater_than"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          comment:
            "message_index of step to loop back to. Steps are assumed to be in the order by message_index. custom_name and intensity members are undefined for this duration type.",
          example: "1",
          name: :duration_step,
          ref_fields: [
            duration_type: "repeat_until_steps_cmplt",
            duration_type: "repeat_until_time",
            duration_type: "repeat_until_distance",
            duration_type: "repeat_until_calories",
            duration_type: "repeat_until_hr_less_than",
            duration_type: "repeat_until_hr_greater_than",
            duration_type: "repeat_until_power_less_than",
            duration_type: "repeat_until_power_greater_than"
          ],
          type: :uint32
        },
        %{
          example: "1",
          name: :duration_calories,
          ref_fields: [duration_type: "calories"],
          type: :uint32,
          units: ["calories"]
        },
        %{
          example: "1",
          name: :duration_hr,
          ref_fields: [duration_type: "hr_less_than", duration_type: "hr_greater_than"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :duration_distance,
          ref_fields: [duration_type: "distance"],
          scale: ~c"d",
          type: :uint32,
          units: ["m"]
        },
        %{
          example: "1",
          name: :duration_time,
          ref_fields: [duration_type: "time", duration_type: "repetition_time"],
          scale: [1000],
          type: :uint32,
          units: ["s"]
        }
      ]
    )

    field(3, :target_type, :wkt_step_target, example: "1")

    field(4, :target_value, :uint32,
      example: "1",
      subfields: [
        %{example: "1", name: :target_stroke_type, ref_fields: [target_type: "swim_stroke"], type: :swim_stroke},
        %{
          example: "1",
          name: :repeat_power,
          ref_fields: [duration_type: "repeat_until_power_less_than", duration_type: "repeat_until_power_greater_than"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          example: "1",
          name: :repeat_hr,
          ref_fields: [duration_type: "repeat_until_hr_less_than", duration_type: "repeat_until_hr_greater_than"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :repeat_calories,
          ref_fields: [duration_type: "repeat_until_calories"],
          type: :uint32,
          units: ["calories"]
        },
        %{
          example: "1",
          name: :repeat_distance,
          ref_fields: [duration_type: "repeat_until_distance"],
          scale: ~c"d",
          type: :uint32,
          units: ["m"]
        },
        %{
          example: "1",
          name: :repeat_time,
          ref_fields: [duration_type: "repeat_until_time"],
          scale: [1000],
          type: :uint32,
          units: ["s"]
        },
        %{
          comment: "# of repetitions",
          example: "1",
          name: :repeat_steps,
          ref_fields: [duration_type: "repeat_until_steps_cmplt"],
          type: :uint32
        },
        %{
          comment: "Power Zone ( 1-7); Custom = 0;",
          example: "1",
          name: :target_power_zone,
          ref_fields: [target_type: "power"],
          type: :uint32
        },
        %{
          comment: "Zone (1-?); Custom = 0;",
          example: "1",
          name: :target_cadence_zone,
          ref_fields: [target_type: "cadence"],
          type: :uint32
        },
        %{
          comment: "hr zone (1-5);Custom =0;",
          example: "1",
          name: :target_hr_zone,
          ref_fields: [target_type: "heart_rate"],
          type: :uint32
        },
        %{
          comment: "speed zone (1-10);Custom =0;",
          example: "1",
          name: :target_speed_zone,
          ref_fields: [target_type: "speed"],
          type: :uint32
        }
      ]
    )

    field(5, :custom_target_value_low, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :custom_target_power_low,
          ref_fields: [target_type: "power"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          example: "1",
          name: :custom_target_cadence_low,
          ref_fields: [target_type: "cadence"],
          type: :uint32,
          units: ["rpm"]
        },
        %{
          example: "1",
          name: :custom_target_heart_rate_low,
          ref_fields: [target_type: "heart_rate"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :custom_target_speed_low,
          ref_fields: [target_type: "speed"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        }
      ]
    )

    field(6, :custom_target_value_high, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :custom_target_power_high,
          ref_fields: [target_type: "power"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          example: "1",
          name: :custom_target_cadence_high,
          ref_fields: [target_type: "cadence"],
          type: :uint32,
          units: ["rpm"]
        },
        %{
          example: "1",
          name: :custom_target_heart_rate_high,
          ref_fields: [target_type: "heart_rate"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :custom_target_speed_high,
          ref_fields: [target_type: "speed"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        }
      ]
    )

    field(7, :intensity, :intensity, example: "1")
    field(8, :notes, :string, example: "50")
    field(9, :equipment, :workout_equipment, example: "1")
    field(10, :exercise_category, :exercise_category, example: "1")
    field(11, :exercise_name, :uint16)
    field(12, :exercise_weight, :uint16, scale: ~c"d", units: ["kg"])
    field(13, :weight_display_unit, :fit_base_unit)
    field(19, :secondary_target_type, :wkt_step_target, example: "1")

    field(20, :secondary_target_value, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :secondary_target_stroke_type,
          ref_fields: [secondary_target_type: "swim_stroke"],
          type: :swim_stroke
        },
        %{
          comment: "Power Zone ( 1-7); Custom = 0;",
          example: "1",
          name: :secondary_target_power_zone,
          ref_fields: [secondary_target_type: "power"],
          type: :uint32
        },
        %{
          comment: "Zone (1-?); Custom = 0;",
          example: "1",
          name: :secondary_target_cadence_zone,
          ref_fields: [secondary_target_type: "cadence"],
          type: :uint32
        },
        %{
          comment: "hr zone (1-5);Custom =0;",
          example: "1",
          name: :secondary_target_hr_zone,
          ref_fields: [secondary_target_type: "heart_rate"],
          type: :uint32
        },
        %{
          comment: "speed zone (1-10);Custom =0;",
          example: "1",
          name: :secondary_target_speed_zone,
          ref_fields: [secondary_target_type: "speed"],
          type: :uint32
        }
      ]
    )

    field(21, :secondary_custom_target_value_low, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :secondary_custom_target_power_low,
          ref_fields: [secondary_target_type: "power"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_cadence_low,
          ref_fields: [secondary_target_type: "cadence"],
          type: :uint32,
          units: ["rpm"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_heart_rate_low,
          ref_fields: [secondary_target_type: "heart_rate"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_speed_low,
          ref_fields: [secondary_target_type: "speed"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        }
      ]
    )

    field(22, :secondary_custom_target_value_high, :uint32,
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :secondary_custom_target_power_high,
          ref_fields: [secondary_target_type: "power"],
          type: :workout_power,
          units: ["% or watts"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_cadence_high,
          ref_fields: [secondary_target_type: "cadence"],
          type: :uint32,
          units: ["rpm"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_heart_rate_high,
          ref_fields: [secondary_target_type: "heart_rate"],
          type: :workout_hr,
          units: ["% or bpm"]
        },
        %{
          example: "1",
          name: :secondary_custom_target_speed_high,
          ref_fields: [secondary_target_type: "speed"],
          scale: [1000],
          type: :uint32,
          units: ["m/s"]
        }
      ]
    )
  end

  message(:exercise_title) do
    field(254, :message_index, :message_index, example: "1")
    field(0, :exercise_category, :exercise_category, example: "1")
    field(1, :exercise_name, :uint16, example: "1")
    field(2, :wkt_step_name, :string, array: true, example: "200")
  end

  message(:schedule) do
    field(0, :manufacturer, :manufacturer,
      comment: "Corresponds to file_id of scheduled workout / course.",
      example: "1"
    )

    field(1, :product, :uint16,
      comment: "Corresponds to file_id of scheduled workout / course.",
      example: "1",
      subfields: [
        %{
          example: "1",
          name: :garmin_product,
          ref_fields: [
            manufacturer: "garmin",
            manufacturer: "dynastream",
            manufacturer: "dynastream_oem",
            manufacturer: "tacx"
          ],
          type: :garmin_product
        },
        %{name: :favero_product, ref_fields: [manufacturer: "favero_electronics"], type: :favero_product}
      ]
    )

    field(2, :serial_number, :uint32z,
      comment: "Corresponds to file_id of scheduled workout / course.",
      example: "1"
    )

    field(3, :time_created, :date_time,
      comment: "Corresponds to file_id of scheduled workout / course.",
      example: "1"
    )

    field(4, :completed, :bool, comment: "TRUE if this activity has been started", example: "1")
    field(5, :type, :schedule, example: "1")
    field(6, :scheduled_time, :local_date_time, example: "1")
  end

  message(:totals) do
    field(254, :message_index, :message_index, example: "1")
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :timer_time, :uint32, comment: "Excludes pauses", example: "1", units: ["s"])
    field(1, :distance, :uint32, example: "1", units: ["m"])
    field(2, :calories, :uint32, example: "1", units: ["kcal"])
    field(3, :sport, :sport, example: "1")
    field(4, :elapsed_time, :uint32, comment: "Includes pauses", example: "1", units: ["s"])
    field(5, :sessions, :uint16, example: "1")
    field(6, :active_time, :uint32, example: "1", units: ["s"])
    field(9, :sport_index, :uint8)
  end

  message(:weight_scale) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :weight, :weight, example: "1", scale: ~c"d", units: ["kg"])
    field(1, :percent_fat, :uint16, example: "1", scale: ~c"d", units: ["%"])
    field(2, :percent_hydration, :uint16, example: "1", scale: ~c"d", units: ["%"])
    field(3, :visceral_fat_mass, :uint16, example: "1", scale: ~c"d", units: ["kg"])
    field(4, :bone_mass, :uint16, example: "1", scale: ~c"d", units: ["kg"])
    field(5, :muscle_mass, :uint16, example: "1", scale: ~c"d", units: ["kg"])
    field(7, :basal_met, :uint16, example: "1", scale: [4], units: ["kcal/day"])
    field(8, :physique_rating, :uint8, example: "1")

    field(9, :active_met, :uint16,
      comment: "~4kJ per kcal, 0.25 allows max 16384 kcal",
      example: "1",
      scale: [4],
      units: ["kcal/day"]
    )

    field(10, :metabolic_age, :uint8, example: "1", units: ["years"])
    field(11, :visceral_fat_rating, :uint8, example: "1")

    field(12, :user_profile_index, :message_index,
      comment:
        "Associates this weight scale message to a user. This corresponds to the index of the user profile message in the weight scale file.",
      example: "1"
    )

    field(13, :bmi, :uint16, example: "1", scale: ~c"\n", units: ["kg/m^2"])
  end

  message(:blood_pressure) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :systolic_pressure, :uint16, example: "1", units: ["mmHg"])
    field(1, :diastolic_pressure, :uint16, example: "1", units: ["mmHg"])
    field(2, :mean_arterial_pressure, :uint16, example: "1", units: ["mmHg"])
    field(3, :map_3_sample_mean, :uint16, example: "1", units: ["mmHg"])
    field(4, :map_morning_values, :uint16, example: "1", units: ["mmHg"])
    field(5, :map_evening_values, :uint16, example: "1", units: ["mmHg"])
    field(6, :heart_rate, :uint8, example: "1", units: ["bpm"])
    field(7, :heart_rate_type, :hr_type, example: "1")
    field(8, :status, :bp_status, example: "1")

    field(9, :user_profile_index, :message_index,
      comment:
        "Associates this blood pressure message to a user. This corresponds to the index of the user profile message in the blood pressure file.",
      example: "1"
    )
  end

  message(:monitoring_info) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])

    field(0, :local_timestamp, :local_date_time,
      comment:
        "Use to convert activity timestamps to local time if device does not support time zone and daylight savings time correction.",
      example: "1",
      units: ["s"]
    )

    field(1, :activity_type, :activity_type, array: true)

    field(3, :cycles_to_distance, :uint16,
      array: true,
      comment: "Indexed by activity_type",
      scale: [5000],
      units: ["m/cycle"]
    )

    field(4, :cycles_to_calories, :uint16,
      array: true,
      comment: "Indexed by activity_type",
      scale: [5000],
      units: ["kcal/cycle"]
    )

    field(5, :resting_metabolic_rate, :uint16, units: ["kcal / day"])
  end

  message(:monitoring) do
    field(253, :timestamp, :date_time,
      comment: "Must align to logging interval, for example, time must be 00:00:00 for daily log.",
      example: "1",
      units: ["s"]
    )

    field(0, :device_index, :device_index,
      comment: "Associates this data to device_info message. Not required for file with single device (sensor).",
      example: "1"
    )

    field(1, :calories, :uint16,
      comment:
        "Accumulated total calories. Maintained by MonitoringReader for each activity_type. See SDK documentation",
      example: "1",
      units: ["kcal"]
    )

    field(2, :distance, :uint32,
      comment: "Accumulated distance. Maintained by MonitoringReader for each activity_type. See SDK documentation.",
      example: "1",
      scale: ~c"d",
      units: ["m"]
    )

    field(3, :cycles, :uint32,
      comment: "Accumulated cycles. Maintained by MonitoringReader for each activity_type. See SDK documentation.",
      example: "1",
      scale: [2],
      subfields: [
        %{
          example: "1",
          name: :strokes,
          ref_fields: [activity_type: "cycling", activity_type: "swimming"],
          scale: [2],
          type: :uint32,
          units: ["strokes"]
        },
        %{
          name: :steps,
          ref_fields: [activity_type: "walking", activity_type: "running"],
          scale: [1],
          type: :uint32,
          units: ["steps"]
        }
      ],
      units: ["cycles"]
    )

    field(4, :active_time, :uint32, example: "1", scale: [1000], units: ["s"])
    field(5, :activity_type, :activity_type, example: "1")
    field(6, :activity_subtype, :activity_subtype, example: "1")
    field(7, :activity_level, :activity_level)
    field(8, :distance_16, :uint16, example: "1", units: ["100 * m"])
    field(9, :cycles_16, :uint16, example: "1", units: ["2 * cycles (steps)"])
    field(10, :active_time_16, :uint16, example: "1", units: ["s"])

    field(11, :local_timestamp, :local_date_time,
      comment: "Must align to logging interval, for example, time must be 00:00:00 for daily log.",
      example: "1"
    )

    field(12, :temperature, :sint16,
      comment: "Avg temperature during the logging interval ended at timestamp",
      scale: ~c"d",
      units: ["C"]
    )

    field(14, :temperature_min, :sint16,
      comment: "Min temperature during the logging interval ended at timestamp",
      scale: ~c"d",
      units: ["C"]
    )

    field(15, :temperature_max, :sint16,
      comment: "Max temperature during the logging interval ended at timestamp",
      scale: ~c"d",
      units: ["C"]
    )

    field(16, :activity_time, :uint16,
      array: 8,
      comment: "Indexed using minute_activity_level enum",
      units: ["minutes"]
    )

    field(19, :active_calories, :uint16, units: ["kcal"])

    field(24, :current_activity_type_intensity, :byte,
      bits: [5, 3],
      comment: "Indicates single type / intensity for duration since last monitoring message.",
      components: [:activity_type, :intensity]
    )

    field(25, :timestamp_min_8, :uint8, units: ["min"])
    field(26, :timestamp_16, :uint16, units: ["s"])
    field(27, :heart_rate, :uint8, units: ["bpm"])
    field(28, :intensity, :uint8, scale: ~c"\n")
    field(29, :duration_min, :uint16, units: ["min"])
    field(30, :duration, :uint32, units: ["s"])
    field(31, :ascent, :uint32, scale: [1000], units: ["m"])
    field(32, :descent, :uint32, scale: [1000], units: ["m"])
    field(33, :moderate_activity_minutes, :uint16, units: ["minutes"])
    field(34, :vigorous_activity_minutes, :uint16, units: ["minutes"])
  end

  message(:monitoring_hr_data) do
    field(253, :timestamp, :date_time,
      comment: "Must align to logging interval, for example, time must be 00:00:00 for daily log.",
      example: "1",
      units: ["s"]
    )

    field(0, :resting_heart_rate, :uint8,
      comment: "7-day rolling average",
      example: "1",
      units: ["bpm"]
    )

    field(1, :current_day_resting_heart_rate, :uint8,
      comment: "RHR for today only. (Feeds into 7-day average)",
      example: "1",
      units: ["bpm"]
    )
  end

  message(:spo2_data) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :reading_spo2, :uint8, scale: [1], units: ["percent"])
    field(1, :reading_confidence, :uint8, scale: [1])
    field(2, :mode, :spo2_measurement_type, comment: "Mode when data was captured")
  end

  message(:hr) do
    field(253, :timestamp, :date_time, example: "1")
    field(0, :fractional_timestamp, :uint16, example: "1", scale: [32768], units: ["s"])

    field(1, :time256, :uint8,
      bits: ~c"\b",
      components: [:fractional_timestamp],
      example: "1",
      scale: [256],
      units: ["s"]
    )

    field(6, :filtered_bpm, :uint8, array: true, example: "1", units: ["bpm"])
    field(9, :event_timestamp, :uint32, array: true, example: "1", scale: [1024], units: ["s"])

    field(10, :event_timestamp_12, :byte,
      accumulate: [true, true, true, true, true, true, true, true, true, true],
      array: true,
      bits: ~c"\f\f\f\f\f\f\f\f\f\f",
      components: [
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp,
        :event_timestamp
      ],
      example: "1",
      scale: [1024, 1024, 1024, 1024, 1024, 1024, 1024, 1024, 1024, 1024],
      units: ["s"]
    )
  end

  message(:stress_level) do
    field(0, :stress_level_value, :sint16)

    field(1, :stress_level_time, :date_time,
      comment: "Time stress score was calculated",
      units: ["s"]
    )
  end

  message(:max_met_data) do
    field(0, :update_time, :date_time, comment: "Time maxMET and vo2 were calculated")
    field(2, :vo2_max, :uint16, scale: ~c"\n", units: ["mL/kg/min"])
    field(5, :sport, :sport)
    field(6, :sub_sport, :sub_sport)
    field(8, :max_met_category, :max_met_category)

    field(9, :calibrated_data, :bool, comment: "Indicates if calibrated data was used in the calculation")

    field(12, :hr_source, :max_met_heart_rate_source,
      comment: "Indicates if the estimate was obtained using a chest strap or wrist heart rate"
    )

    field(13, :speed_source, :max_met_speed_source,
      comment: "Indidcates if the estimate was obtained using onboard GPS or connected GPS"
    )
  end

  message(:memo_glob) do
    field(250, :part_index, :uint32, comment: "Sequence number of memo blocks")
    field(0, :memo, :byte, array: true, comment: "Deprecated. Use data field.")
    field(1, :mesg_num, :mesg_num, comment: "Message Number of the parent message")

    field(2, :parent_index, :message_index, comment: "Index of mesg that this glob is associated with.")

    field(3, :field_num, :uint8, comment: "Field within the parent that this glob is associated with")

    field(4, :data, :uint8z,
      array: true,
      comment: "Block of utf8 bytes. Note, mutltibyte characters may be split across adjoining memo_glob messages."
    )
  end

  message(:sleep_level) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :sleep_level, :sleep_level)
  end

  message(:ant_channel_id) do
    field(0, :channel_number, :uint8)
    field(1, :device_type, :uint8z)
    field(2, :device_number, :uint16z)
    field(3, :transmission_type, :uint8z)
    field(4, :device_index, :device_index)
  end

  message(:ant_rx) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :fractional_timestamp, :uint16, example: "1", scale: [32768], units: ["s"])
    field(1, :mesg_id, :byte, example: "1")

    field(2, :mesg_data, :byte,
      array: true,
      bits: ~c"\b\b\b\b\b\b\b\b\b",
      components: [:channel_number, :data, :data, :data, :data, :data, :data, :data, :data],
      example: "9"
    )

    field(3, :channel_number, :uint8, example: "1")
    field(4, :data, :byte, array: true, example: "8")
  end

  message(:ant_tx) do
    field(253, :timestamp, :date_time, example: "1", units: ["s"])
    field(0, :fractional_timestamp, :uint16, example: "1", scale: [32768], units: ["s"])
    field(1, :mesg_id, :byte, example: "1")

    field(2, :mesg_data, :byte,
      array: true,
      bits: ~c"\b\b\b\b\b\b\b\b\b",
      components: [:channel_number, :data, :data, :data, :data, :data, :data, :data, :data],
      example: "9"
    )

    field(3, :channel_number, :uint8, example: "1")
    field(4, :data, :byte, array: true, example: "8")
  end

  message(:exd_screen_configuration) do
    field(0, :screen_index, :uint8, example: "1")
    field(1, :field_count, :uint8, comment: "number of fields in screen", example: "1")
    field(2, :layout, :exd_layout, example: "1")
    field(3, :screen_enabled, :bool, example: "1")
  end

  message(:exd_data_field_configuration) do
    field(0, :screen_index, :uint8, example: "1")

    field(1, :concept_field, :byte,
      bits: [4, 4],
      components: [:field_id, :concept_count],
      example: "1"
    )

    field(2, :field_id, :uint8, example: "1")
    field(3, :concept_count, :uint8, example: "1")
    field(4, :display_type, :exd_display_type, example: "1")
    field(5, :title, :string, array: 32, example: "1")
  end

  message(:exd_data_concept_configuration) do
    field(0, :screen_index, :uint8, example: "1")

    field(1, :concept_field, :byte,
      bits: [4, 4],
      components: [:field_id, :concept_index],
      example: "1"
    )

    field(2, :field_id, :uint8, example: "1")
    field(3, :concept_index, :uint8, example: "1")
    field(4, :data_page, :uint8, example: "1")
    field(5, :concept_key, :uint8, example: "1")
    field(6, :scaling, :uint8, example: "1")
    field(8, :data_units, :exd_data_units, example: "1")
    field(9, :qualifier, :exd_qualifiers, example: "1")
    field(10, :descriptor, :exd_descriptors, example: "1")
    field(11, :is_signed, :bool, example: "1")
  end

  message(:dive_summary) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :reference_mesg, :mesg_num)
    field(1, :reference_index, :message_index)
    field(2, :avg_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])
    field(3, :max_depth, :uint32, comment: "0 if above water", scale: [1000], units: ["m"])

    field(4, :surface_interval, :uint32,
      comment: "Time since end of last dive",
      scale: [1],
      units: ["s"]
    )

    field(5, :start_cns, :uint8, scale: [1], units: ["percent"])
    field(6, :end_cns, :uint8, scale: [1], units: ["percent"])
    field(7, :start_n2, :uint16, scale: [1], units: ["percent"])
    field(8, :end_n2, :uint16, scale: [1], units: ["percent"])
    field(9, :o2_toxicity, :uint16, units: ["OTUs"])
    field(10, :dive_number, :uint32)
    field(11, :bottom_time, :uint32, scale: [1000], units: ["s"])

    field(12, :avg_pressure_sac, :uint16,
      comment: "Average pressure-based surface air consumption",
      scale: ~c"d",
      units: ["bar/min"]
    )

    field(13, :avg_volume_sac, :uint16,
      comment: "Average volumetric surface air consumption",
      scale: ~c"d",
      units: ["L/min"]
    )

    field(14, :avg_rmv, :uint16,
      comment: "Average respiratory minute volume",
      scale: ~c"d",
      units: ["L/min"]
    )

    field(15, :descent_time, :uint32,
      comment: "Time to reach deepest level stop",
      scale: [1000],
      units: ["s"]
    )

    field(16, :ascent_time, :uint32,
      comment: "Time after leaving bottom until reaching surface",
      scale: [1000],
      units: ["s"]
    )

    field(17, :avg_ascent_rate, :sint32,
      comment: "Average ascent rate, not including descents or stops",
      scale: [1000],
      units: ["m/s"]
    )

    field(22, :avg_descent_rate, :uint32,
      comment: "Average descent rate, not including ascents or stops",
      scale: [1000],
      units: ["m/s"]
    )

    field(23, :max_ascent_rate, :uint32,
      comment: "Maximum ascent rate",
      scale: [1000],
      units: ["m/s"]
    )

    field(24, :max_descent_rate, :uint32,
      comment: "Maximum descent rate",
      scale: [1000],
      units: ["m/s"]
    )

    field(25, :hang_time, :uint32,
      comment: "Time spent neither ascending nor descending",
      scale: [1000],
      units: ["s"]
    )
  end

  message(:hrv) do
    field(0, :time, :uint16,
      array: true,
      comment: "Time between beats",
      example: "1",
      scale: [1000],
      units: ["s"]
    )
  end

  message(:beat_intervals) do
    field(253, :timestamp, :date_time)
    field(0, :timestamp_ms, :uint16, comment: "Milliseconds past date_time", units: ["ms"])

    field(1, :time, :uint16,
      array: true,
      comment: "Array of millisecond times between beats",
      units: ["ms"]
    )
  end

  message(:hrv_status_summary) do
    field(253, :timestamp, :date_time)

    field(0, :weekly_average, :uint16,
      comment: "7 day RMSSD average over sleep",
      scale: [128],
      units: ["ms"]
    )

    field(1, :last_night_average, :uint16,
      comment: "Last night RMSSD average over sleep",
      scale: [128],
      units: ["ms"]
    )

    field(2, :last_night_5_min_high, :uint16,
      comment: "5 minute high RMSSD value over sleep",
      scale: [128],
      units: ["ms"]
    )

    field(3, :baseline_low_upper, :uint16,
      comment: "3 week baseline, upper boundary of low HRV status",
      scale: [128],
      units: ["ms"]
    )

    field(4, :baseline_balanced_lower, :uint16,
      comment: "3 week baseline, lower boundary of balanced HRV status",
      scale: [128],
      units: ["ms"]
    )

    field(5, :baseline_balanced_upper, :uint16,
      comment: "3 week baseline, upper boundary of balanced HRV status",
      scale: [128],
      units: ["ms"]
    )

    field(6, :status, :hrv_status)
  end

  message(:hrv_value) do
    field(253, :timestamp, :date_time)
    field(0, :value, :uint16, comment: "5 minute RMSSD", scale: [128], units: ["ms"])
  end

  message(:respiration_rate) do
    field(253, :timestamp, :date_time)

    field(0, :respiration_rate, :sint16,
      comment: "Breaths * 100 /min, -300 indicates invalid, -200 indicates large motion, -100 indicates off wrist",
      scale: ~c"d",
      units: ["breaths/min"]
    )
  end

  message(:tank_update) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :sensor, :ant_channel_id)
    field(1, :pressure, :uint16, scale: ~c"d", units: ["bar"])
  end

  message(:tank_summary) do
    field(253, :timestamp, :date_time, units: ["s"])
    field(0, :sensor, :ant_channel_id)
    field(1, :start_pressure, :uint16, scale: ~c"d", units: ["bar"])
    field(2, :end_pressure, :uint16, scale: ~c"d", units: ["bar"])
    field(3, :volume_used, :uint32, scale: ~c"d", units: ["L"])
  end

  message(:sleep_assessment) do
    field(0, :combined_awake_score, :uint8,
      comment:
        "Average of awake_time_score and awakenings_count_score. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(1, :awake_time_score, :uint8,
      comment:
        "Score that evaluates the total time spent awake between sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(2, :awakenings_count_score, :uint8,
      comment:
        "Score that evaluates the number of awakenings that interrupt sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(3, :deep_sleep_score, :uint8,
      comment:
        "Score that evaluates the amount of deep sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(4, :sleep_duration_score, :uint8,
      comment:
        "Score that evaluates the quality of sleep based on sleep stages, heart-rate variability and possible awakenings during the night. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(5, :light_sleep_score, :uint8,
      comment:
        "Score that evaluates the amount of light sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(6, :overall_sleep_score, :uint8,
      comment:
        "Total score that summarizes the overall quality of sleep, combining sleep duration and quality. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(7, :sleep_quality_score, :uint8,
      comment:
        "Score that evaluates the quality of sleep based on sleep stages, heart-rate variability and possible awakenings during the night. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(8, :sleep_recovery_score, :uint8,
      comment:
        "Score that evaluates stress and recovery during sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(9, :rem_sleep_score, :uint8,
      comment:
        "Score that evaluates the amount of REM sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(10, :sleep_restlessness_score, :uint8,
      comment:
        "Score that evaluates the amount of restlessness during sleep. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(11, :awakenings_count, :uint8, comment: "The number of awakenings during sleep.")

    field(14, :interruptions_score, :uint8,
      comment:
        "Score that evaluates the sleep interruptions. If valid: 0 (worst) to 100 (best). If unknown: FIT_UINT8_INVALID."
    )

    field(15, :average_stress_during_sleep, :uint16,
      comment: "Excludes stress during awake periods in the sleep window",
      scale: ~c"d"
    )
  end
end