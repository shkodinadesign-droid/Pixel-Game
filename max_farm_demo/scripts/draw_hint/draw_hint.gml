/// @func draw_hint(_text, _x, _y, _triangle)
/// @desc Рисует подсказку в рамочке над точкой (_x,_y)

function draw_hint(_text, _x, _y, _triangle)
{
    var text = argument0;
    var cx   = argument1;
    var topY = argument2;
    var tri  = argument3;

    // размеры текста
    draw_set_font(fnt_ui); // твой шрифт с кириллицей!
    var tw = string_width(text);
    var th = string_height(text);

    // рамка
    var pad = 4;
    var gap = 12;
    var bx1 = cx - tw * 0.5 - pad;
    var by1 = topY - th - gap - pad;
    var bx2 = cx + tw * 0.5 + pad;
    var by2 = topY - gap + pad;

    // фон
    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(bx1, by1, bx2, by2, false);
    draw_set_alpha(1);

    // белая рамка
    draw_set_color(c_white);
    draw_rectangle(bx1, by1, bx2, by2, true);

    // "хвостик"
    if (tri) {
        draw_triangle(cx-6, by2, cx+6, by2, cx, by2+8, false);
    }

    // текст
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text((bx1+bx2)*0.5, (by1+by2)*0.5, text);
}
   