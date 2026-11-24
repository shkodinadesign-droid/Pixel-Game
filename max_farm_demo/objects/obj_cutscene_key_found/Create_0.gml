// ===== МАКС НАШЛА КЛЮЧ (CREATE) =====
// Короткая сцена у камня со звёздочкой: ключ поднимается из коробки над головой Макс, она подпрыгивает
// от радости, вокруг искорки. Потом ключ — в хотбар, и диалог «Ура! Нашла!» -> записка Сони.
// Пока идёт сцена, сама Макс скрыта — её рисует эта сцена (spr_max_idle_down, 32x48, левый верх).
global.control_locked = true;
global.secret_cache_found = true;          // камень уже отодвинут, видна ямка
global.has_secret_key     = true;

t  = 0;
T_RISE = 40;                               // ключ поднимается
T_JOY  = 170;                              // Макс прыгает и радуется
T_END  = 210;

p  = instance_find(obj_max, 0);
mx = p.x; my = p.y;
with (p) { visible = false; direction_facing = "down"; sprite_index = spr_max_idle_down; }
depth = p.depth - 1;

// откуда поднимается ключ — из ямки под камнем
var _s = instance_exists(obj_secret_cache_stone) ? instance_find(obj_secret_cache_stone, 0) : noone;
kx0 = (_s != noone) ? (_s.bbox_left + _s.bbox_right) * 0.5 : mx + 16;
ky0 = (_s != noone) ? _s.bbox_bottom - 4 : my + 40;
kx = kx0; ky = ky0;

hop    = 0;                                // высота прыжка Макс
sparks = [];                               // искорки {x, y, vx, vy, life}
if (audio_exists(snd_harvest)) audio_play_sound(snd_harvest, 1, false, 0.7);
