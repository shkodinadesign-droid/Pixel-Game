// ===== ФЕРМЕР ДЖО (DRAW) =====
// Пока идёт разговор с ним (продавец obj_joe_seller в диалоге) — позы разговора, иначе курит (анимация спрайта)
var _s = instance_find(obj_joe_seller, 0);
if (_s != noone && _s.shop_state != 0 && _s.shop_state != 4) {
    draw_sprite(spr_farmer_joe_talk, [0, 1, 2, 1][(current_time div 300) mod 4], x, y);
} else {
    draw_self();
}
