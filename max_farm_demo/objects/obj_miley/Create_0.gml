// === МЭГГИ (CREATE) ===
persistent  = true;
visible     = false;
state       = "entering";
move_speed  = 1.5;

sprite_index = spr_maggie_walk_left;
image_speed  = 1;
image_index  = 0;
image_xscale = 1;

// Начинает за правым краем экрана, y выровняем в Step
target_x = 0;
target_y = 0;

// Встроенный диалог
dlg_step      = 1;
dlg_show      = false;
dlg_click_prev = mouse_check_button(mb_left);

// Цвет Мэгги (тёплый)
dlg_miley_col = make_color_rgb(255, 180, 100);
dlg_max_col   = make_color_rgb(255, 210, 100);
