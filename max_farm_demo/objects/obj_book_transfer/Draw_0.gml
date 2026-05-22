// ===== АНИМАЦИЯ ПЕРЕДАЧИ ДНЕВНИКА - DRAW =====

if (phase == "give_diary") {
    // Вычисляем текущий кадр анимации
    var frame = floor((phase_timer / anim_duration) * (anim_frames - 1));
    frame = clamp(frame, 0, anim_frames - 1);

    // Рисуем Мэгги с анимацией передачи дневника
    draw_sprite(spr_maggie_idle_diary, frame, maggie_x, maggie_y);

    // Рисуем Макс (смотрит на Мэгги - вправо)
    draw_sprite(spr_max_idle_right, 0, max_x, max_y);
}

if (phase == "finishing") {
    // Последний кадр анимации - застываем
    var frame = anim_frames - 1;

    // Рисуем Мэгги (последний кадр)
    draw_sprite(spr_maggie_idle_diary, frame, maggie_x, maggie_y);

    // Рисуем Макс
    draw_sprite(spr_max_idle_right, 0, max_x, max_y);
}
