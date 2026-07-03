phase_timer++;
frog_anim++;

switch (phase) {

    case 0: // Экран постепенно темнеет до ночи
        darkness = min(darkness + 0.012, 0.72);
        if (darkness >= 0.72) {
            phase       = 1;
            phase_timer = 0;
        }
    break;

    case 1: // Лягушонок идёт к пуддингу
        frog_dir = 1;
        var _dx = target_x - x;
        if (abs(_dx) > frog_speed) {
            x += frog_speed * sign(_dx);
        } else {
            x     = target_x;
            phase = 2;
            phase_timer = 0;
        }
    break;

    case 2: // Ест пуддинг (~2 сек)
        if (phase_timer > 120) {
            // Пуддинг исчезает
            global.pudding_on_porch = false;
            if (instance_exists(obj_pudding_icon)) obj_pudding_icon.visible = false;
            phase       = 3;
            phase_timer = 0;
        }
    break;

    case 3: // Оставляет книжку и уходит влево
        // Оставляем флаг волшебного дневника
        if (phase_timer == 1) {
            global.magic_diary_on_porch = true;
        }
        frog_dir = -1;
        var _exit_x = camera_get_view_x(view_camera[0]) - 60;
        if (x > _exit_x) {
            x -= frog_speed;
        } else {
            phase       = 4;
            phase_timer = 0;
        }
    break;

    case 4: // Светлеет и завершаем (~2 сек)
        darkness = max(darkness - 0.008, 0);
        if (phase_timer > 160) {
            if (instance_exists(obj_max)) obj_max.visible = true;
            global.control_locked = false;
            instance_destroy();
        }
    break;
}
