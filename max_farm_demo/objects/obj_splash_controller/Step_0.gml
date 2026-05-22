t += 1;

var confirm = keyboard_check_pressed(vk_enter)
           || keyboard_check_pressed(vk_space)
           || mouse_check_button_pressed(mb_left);

switch (state) {

    case SplashState.FadeIn:
        fade_alpha = max(0, fade_alpha - fade_in_speed);
        if (fade_alpha <= 0) {
            fade_alpha = 0;
            t = 0;
            state = SplashState.Wait;
        }
    break;

    case SplashState.Wait:
        if ((allow_skip && confirm) || t >= wait_time) {
            state = SplashState.FadeOut;
        }
    break;

    case SplashState.FadeOut:
        fade_alpha = min(1, fade_alpha + fade_out_speed);
        if (fade_alpha >= 1) {
            room_goto(room_title); // ← ВАЖНО: только это
        }
    break;
}

