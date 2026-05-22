// === МАЙЛИ (CREATE) ===
persistent  = true;
visible     = false;
state       = "entering";
move_speed  = 1.5;

sprite_index = spr_Miley;
image_speed  = 0;
image_index  = 0;
image_xscale = -1; // идёт влево (справа налево)

// Начинает за правым краем экрана, y выровняем в Step
target_x = 0;
target_y = 0;

// Встроенный диалог
dlg_step      = 1;
dlg_show      = false;
dlg_click_prev = mouse_check_button(mb_left);

// Цвет Майли
dlg_miley_col = make_color_rgb(120, 200, 240);
dlg_max_col   = make_color_rgb(255, 210, 100);
