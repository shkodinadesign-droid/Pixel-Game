// ===== ДОСКА ОБЪЯВЛЕНИЙ (STEP) =====
// Подходим и жмём E — открывается окно с объявлениями жителей

if (!variable_global_exists("control_locked")) global.control_locked = false;

near_player = false;
if (instance_exists(obj_max)) {
    var p = instance_find(obj_max, 0);
    var _foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
    var _foot_y  = p.bbox_bottom;
    var _cx      = (bbox_left + bbox_right) * 0.5;
    near_player  = point_distance(_cx, bbox_bottom, _foot_cx, _foot_y) < 64;
}

if (near_player && !global.control_locked && !instance_exists(obj_ui_bulletin_board)
&&  keyboard_check_pressed(ord("E"))) {
    var _lyr = layer_get_id("letter");
    if (_lyr == -1) _lyr = layer;
    instance_create_layer(0, 0, _lyr, obj_ui_bulletin_board);
}
