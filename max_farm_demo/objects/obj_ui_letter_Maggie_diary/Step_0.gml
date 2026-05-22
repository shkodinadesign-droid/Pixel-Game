// ===== MEGGI DIARY DIALOG STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

if ((hover && click_press) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    // Запускаем анимацию передачи книги
    var _lyr = layer_get_id("Max");
    if (_lyr == -1) _lyr = layer;
    instance_create_layer(0, 0, _lyr, obj_book_transfer);

    instance_destroy();
}
