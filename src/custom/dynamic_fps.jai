Dynamic_Fps :: struct {
    min_s := cast(float64) QUICK_FRAME_DT;
    max_s := cast(float64) MAX_FRAME_DT;

    falloff_s := 10;

    last_event_time: Apollo_Time;
}

on_event :: (using state: *Dynamic_Fps) {
    //print("Event\n");
    last_event_time = current_time_monotonic();
}

get_sleep_duration :: (using state: *Dynamic_Fps) -> s32 {
    current_time := current_time_monotonic();
    last_event_duration := to_float64_seconds(current_time - last_event_time);

    percent := min(last_event_duration / falloff_s, 1.0);
    percent *= percent;

    sleep_duration := min_s + (max_s - min_s) * percent;

    work_duration := to_float64_seconds(current_time - frame_time);
    result    := max(min_s, sleep_duration - work_duration);
    result_ms := cast(s32) (1000.0 * result);

    //print("Sleep duration: % - % - %\n", sleep_duration, result, result_ms);

    return result_ms;
}

dynamic_fps_state: Dynamic_Fps;