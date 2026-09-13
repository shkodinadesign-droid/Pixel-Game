/// @func scr_dialog_draw_bg(_x, _y, _w, _h)
/// @desc Рисует фон диалогового окна спрайтом spr_dialog_window вместо примитивов

function scr_dialog_draw_bg(_x, _y, _w, _h)
{
    draw_sprite_stretched(spr_dialog_window, 0, _x, _y, _w, _h);
}

/// @func scr_dialog_tag_rect(_win_x, _win_y, _win_w, _win_h)
/// @desc Возвращает [x1, y1, x2, y2] ячейки-бирки с именем в масштабе текущего окна

function scr_dialog_tag_rect(_win_x, _win_y, _win_w, _win_h)
{
    var _sx = _win_w / 580;
    var _sy = _win_h / 234;
    return [_win_x + 42 * _sx, _win_y + 19 * _sy, _win_x + 245 * _sx, _win_y + 62 * _sy];
}

/// @func scr_dialog_body_top(_win_x, _win_y, _win_w, _win_h)
/// @desc Возвращает Y-координату начала основного текста (под биркой)

function scr_dialog_body_top(_win_x, _win_y, _win_w, _win_h)
{
    return _win_y + 74 * (_win_h / 234) + 10;
}

/// @func scr_dialog_draw_speaker(_win_x, _win_y, _win_w, _win_h, _name)
/// @desc Рисует имя говорящего жирным чёрным по центру ячейки-бирки

function scr_dialog_draw_speaker(_win_x, _win_y, _win_w, _win_h, _name)
{
    var _r = scr_dialog_tag_rect(_win_x, _win_y, _win_w, _win_h);
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(_r[0] + 8, (_r[1] + _r[3]) / 2, _name);
}

/// @func scr_dialog_draw_portrait(_win_x, _win_y, _win_w, _win_h, _btn_y1, _sprite, _size)
/// @desc Рисует деревянную плашку с портретом справа (между биркой и кнопкой).
///       Возвращает макс. ширину текста слева от портрета — использовать в draw_text_ext.

function scr_dialog_draw_portrait(_win_x, _win_y, _win_w, _win_h, _btn_y1, _sprite, _size)
{
    var _scale_x = _win_w / 580;
    var _scale_y = _win_h / 234;

    var _px2 = _win_x + 565 * _scale_x - 8;
    var _px1 = _px2 - _size;
    var _ptop = _win_y + 49 * _scale_y;
    var _py1 = _ptop + (_btn_y1 - _ptop - _size) / 2;
    var _py2 = _py1 + _size;

    draw_set_color(make_color_rgb(60, 38, 20));
    draw_roundrect_ext(_px1, _py1, _px2, _py2, 10, 10, false);
    draw_set_color(make_color_rgb(120, 85, 50));
    draw_roundrect_ext(_px1, _py1, _px2, _py2, 10, 10, true);

    var _ppad = 8;
    var _pscale = (_size - _ppad * 2) / sprite_get_width(_sprite);
    draw_sprite_ext(_sprite, 0, _px1 + _ppad, _py1 + _ppad, _pscale, _pscale, 0, c_white, 1);

    var _text_x = _win_x + 15 * _scale_x + 8;
    return _px1 - _text_x - 16;
}

/// @func scr_dialog_draw_button(_x1, _y1, _x2, _y2, _label, _hover)
/// @desc Рисует зелёную кнопку со скруглёнными углами (радиус 16)

function scr_dialog_draw_button(_x1, _y1, _x2, _y2, _label, _hover)
{
    draw_set_color(_hover ? make_color_rgb(110, 195, 100) : make_color_rgb(80, 165, 70));
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 16, 16, false);
    draw_set_color(make_color_rgb(45, 105, 40));
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 16, 16, true);

    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text((_x1 + _x2) / 2, (_y1 + _y2) / 2, _label);
}
