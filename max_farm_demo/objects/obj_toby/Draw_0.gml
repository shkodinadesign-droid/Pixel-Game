// ===== ТОБИ (DRAW) — спрайты spr_toby_* 48x48 (v2, tools/characters/toby_v2.py), начало — низ по центру =====
if (state == "note") exit;                                   // уже ушёл — только мысль Макс в GUI
var _spr = spr_toby_idle_down, _fr = ((current_time div 150) mod 24 == 0) ? 1 : 0;
if (state == "enter" || state == "leave") {
    if (move_v) {
        _spr = (vdir < 0) ? spr_toby_walk_up : spr_toby_walk_down;
        _fr  = (current_time div 150) mod 4;
    } else {
        _spr = (face < 0) ? spr_toby_walk_left : spr_toby_walk_right;
        _fr  = (current_time div 110) mod 8;
    }
} else if (state == "talk" && lines[dlg_i][0] == "Тоби:") {
    _spr = spr_toby_talk; _fr = [0, 1, 2, 1][(current_time div 300) mod 4];
}
draw_sprite(_spr, _fr, x, y);
