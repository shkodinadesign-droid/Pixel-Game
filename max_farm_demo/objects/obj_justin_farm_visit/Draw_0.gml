// ===== ДЖАСТИН НА ФЕРМЕ (DRAW) — спрайты 32x56, начало — левый верх =====
var _spr = spr_justin_idle_down, _fr = 0;
var _f = (look != "") ? look : face;
if (moving) {
    _fr = (current_time div 150) mod 4;
    switch (_f) {
        case "left":  _spr = spr_justin_idle_walk_left_strip4;   break;
        case "right": _spr = spr_justin_idle_walk_rightt_strip4; break;
        case "up":    _spr = spr_justin_idle_walk_up_strip4;     break;
        default:      _spr = spr_justin_walk_down;
    }
} else {
    // стоит: боковые/спина — первый кадр ходьбы, лицом — idle_down
    switch (_f) {
        case "left":  _spr = spr_justin_idle_walk_left_strip4;   break;
        case "right": _spr = spr_justin_idle_walk_rightt_strip4; break;
        case "up":    _spr = spr_justin_idle_walk_up_strip4;     break;
        default:      _spr = spr_justin_idle_down;
    }
}
draw_sprite(_spr, _fr, x, y);
