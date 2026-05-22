

// запуск фейда, если кровать сказала «спим»
if (global.is_sleeping && !fading) {
    fading = true;
}

// плавно затемняем
if (fading) {
    fade_alpha = clamp(fade_alpha + 0.03, 0, 1);
    if (fade_alpha >= 1) {
        // когда стало совсем темно — переносим и сбрасываем состояние
        global.is_sleeping = false;
        fading = false;
        fade_alpha = 0;
        room_goto(target_room);
    }
}