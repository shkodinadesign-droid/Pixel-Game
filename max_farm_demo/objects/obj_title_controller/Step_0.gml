/// STEP: Title logic (with debug)

show_debug_message("TITLE STEP RUNNING, room=" + room_get_name(room));

t += 1;

var confirm =
    keyboard_check_pressed(vk_enter) ||
    keyboard_check_pressed(vk_space) ||
    mouse_check_button_pressed(mb_left);

switch (state) {

    case TitleState.FadeIn:
        fade_alpha = max(0, fade_alpha - fade_in_speed);

        if (fade_alpha <= 0) {
            fade_alpha = 0;

            if (!played_jingle && snd_title_idx != -1) {
                audio_play_sound(snd_title_idx, 1, false);
                played_jingle = true;
            }

            state = TitleState.Wait;
        }
    break;

    case TitleState.Wait:
        if (confirm) {
            show_debug_message("TITLE CONFIRM PRESSED");
            state = TitleState.FadeOut;
        }
    break;

    case TitleState.FadeOut:
        fade_alpha = min(1, fade_alpha + fade_out_speed);

        if (fade_alpha >= 1) {
            show_debug_message("TITLE FADEOUT DONE -> goto rm_farm");

            room_goto(rm_farm);   // ← ПЕРЕХОД В ФЕРМУ
            instance_destroy();
            exit;
        }
    break;
}
