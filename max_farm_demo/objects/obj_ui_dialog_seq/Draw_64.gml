// ===== ДИАЛОГ ИЗ НЕСКОЛЬКИХ СТРАНИЦ (DRAW GUI) =====

if (array_length(pages) == 0) exit;
if (layout_page != page) seq_layout();
var _p = pages[page];

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

scr_dialog_draw_bg(win_x, win_y, win_w, win_h);
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, _p.speaker);

// Портрет справа: Макс — её портрет, лягушонок — спрайт лягушонка (масштаб 2:1, целый)
var _spr = (_p.who == "frog") ? spr_frog_idle_down : spr_max_portrait;
var _text_w = scr_dialog_draw_portrait(win_x, win_y, win_w, win_h, btn_y1, _spr, portrait_size);

var tx = win_x + 15 * (win_w / 580) + 8;
var ty = scr_dialog_body_top(win_x, win_y, win_w, win_h);
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
for (var i = 0; i < array_length(_p.lines); i++) {
    draw_text_ext(tx, ty, _p.lines[i], line_h, _text_w);
    ty += line_h;
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);
scr_dialog_draw_button(btn_x1, btn_y1, btn_x2, btn_y2, btn_label, hover);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
