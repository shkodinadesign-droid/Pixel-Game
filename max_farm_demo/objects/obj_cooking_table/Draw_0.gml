// ===== OBJ_COOKING_TABLE DRAW =====
draw_self();

if (!variable_global_exists("justin_bakery_intro_done")) global.justin_bakery_intro_done = false;
// Подсказка только после визита Джастина
if (!global.justin_bakery_intro_done) exit;

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _ctx  = (bbox_left + bbox_right) / 2;
        var _dist = point_distance(_ctx, (bbox_top + bbox_bottom) / 2, obj_max.x, obj_max.y);
        if (_dist < 96) {
            draw_hint("[E] Готовить", _ctx, bbox_top - 6, true);
        }
    }
}
