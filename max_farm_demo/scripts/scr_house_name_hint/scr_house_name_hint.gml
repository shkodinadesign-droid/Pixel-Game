/// @func scr_house_name_hint(_name)
/// @desc Вызывать из Draw GUI дома: когда Макс подходит к дому, над крышей появляется табличка с названием.
///       Макс «рядом» — её ступни в прямоугольнике маски дома, расширенном на 32 px в стороны и на 64 px вниз (перед фасадом).
function scr_house_name_hint(_name)
{
    if (!instance_exists(obj_max)) exit;
    if (variable_global_exists("control_locked") && global.control_locked) exit;   // не поверх диалогов и меню

    var _fx = (obj_max.bbox_left + obj_max.bbox_right) * 0.5;
    var _fy = obj_max.bbox_bottom;
    if (_fx < bbox_left - 32 || _fx > bbox_right + 32 || _fy < bbox_top - 16 || _fy > bbox_bottom + 64) exit;

    // над крышей: верх спрайта, мировые координаты -> GUI
    var _cam = view_camera[0];
    var _wx  = (bbox_left + bbox_right) * 0.5;
    var _wy  = y - sprite_yoffset * image_yscale + 8;
    var _gx  = (_wx - camera_get_view_x(_cam)) / camera_get_view_width(_cam)  * display_get_gui_width();
    var _gy  = (_wy - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height();
    _gy = max(_gy, 40);                                                          // крыша за краем экрана — табличка у верхнего края
    draw_hint(_name, _gx, _gy, true);
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}
