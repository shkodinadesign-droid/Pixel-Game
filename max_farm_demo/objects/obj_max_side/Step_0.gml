// ===== МАКС В ПЕЩЕРЕ (STEP) =====
var _lock = frozen || global.control_locked;
var _l  = !_lock && (keyboard_check(vk_left)  || keyboard_check(ord("A")));
var _r  = !_lock && (keyboard_check(vk_right) || keyboard_check(ord("D")));
var _jp = !_lock && (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")));
var _jh = keyboard_check(vk_space) || keyboard_check(vk_up) || keyboard_check(ord("W"));

hsp = (_r - _l) * MOVE;
if (hsp != 0) facing = sign(hsp);

coyote = on_ground ? 6 : max(0, coyote - 1);
jbuf   = _jp ? 8 : max(0, jbuf - 1);
if (jbuf > 0 && coyote > 0) {
    vsp = JUMP_V; jbuf = 0; coyote = 0; on_ground = false; jumps += 1;
}
if (!_jh && vsp < -3) vsp = -3;          // отпустила — прыжок ниже
vsp = min(vsp + GRAV, 10);

// по горизонтали
if (hsp != 0) {
    if (side_box_hit(x + hsp, y)) {
        var _s = sign(hsp), _n = 0;
        while (_n < 4 && !side_box_hit(x + _s, y)) { x += _s; _n++; }
    } else x += hsp;
}
x = clamp(x, 0, room_width - SIDE_BW);

// по вертикали
var _ny = y + vsp;
if (vsp > 0) {
    if (side_box_hit(x, _ny)) {
        var _n = 0;
        while (_n < 12 && !side_box_hit(x, y + 1)) { y += 1; _n++; }
        vsp = 0;
    } else {
        var _top = side_oneway_land(x, y + SIDE_BH, _ny + SIDE_BH);
        if (_top >= 0) { y = _top - SIDE_BH; vsp = 0; }
        else y = _ny;
    }
} else if (vsp < 0) {
    if (side_box_hit(x, _ny)) {
        var _n = 0;
        while (_n < 12 && !side_box_hit(x, y - 1)) { y -= 1; _n++; }
        vsp = 0;
    } else y = _ny;
}
on_ground = (vsp >= 0) && (side_box_hit(x, y + 1) || side_on_oneway(x, y + SIDE_BH));

if (on_ground && hsp != 0) anim_t += 0.18; else if (on_ground) anim_t = 0;
if (hurt_t > 0) hurt_t -= 1;
