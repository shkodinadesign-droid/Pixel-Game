// ===== НОЧЬ: ЛЯГУШОНОК И КАРТА (CREATE) =====
// Запускается obj_day_controller на ферме после сна, когда пуддинг стоит на камне у забора огорода.
// Макс спит — её не видно, сцену видит только игрок. Лягушонок не говорит (голос и характер — в лесу).
// Сценарий: появляется между грядками -> выглядывает -> оглядывается -> прыгает через забор к миске ->
// нюхает -> пробует кусочек -> быстро съедает -> достаёт карту, кладёт рядом с пустой миской, поправляет ->
// уходит в темноту -> возвращается за последней крошкой -> убегает. Потом рассвет и утро в доме.
global.control_locked = true;
if (instance_exists(obj_max)) obj_max.visible = false;
if (instance_exists(obj_pudding_icon)) obj_pudding_icon.visible = false;   // миску рисует сцена (кадры spr_pudding_eaten)

phase       = 2;     // 2 — затемнение, 3 — надпись, 4 — лягушонок (подсцены st), 7 — рассвет, 8 — утро
phase_timer = 0;
darkness    = 1;
frog_anim   = 0;
text_alpha  = 0;
NIGHT_DARK  = 0.62;  // ночь, но лягушонка видно

// Миска на камне (левый верх спрайта 32x32)
bowl_x = global.PUDDING_SPOT_X;
bowl_y = global.PUDDING_SPOT_Y;
bowl_fr = 0;          // кадр spr_pudding_eaten: 0 целый, 1 кусочек, 2 половина, 3 крошка, 4 пусто

// Точки лягушонка (левый верх спрайта 32x32)
hide_x = bowl_x - 66;  hide_y = bowl_y + 22;   // между грядками, за правым забором огорода
eat_x  = bowl_x + 34;  eat_y  = bowl_y + 4;    // справа от миски, лицом к ней
map_tx = bowl_x + 18;  map_ty = bowl_y + 54;   // карта (центр) — под камнем, рядом с миской
drop_x = bowl_x + 26;  drop_y = bowl_y + 34;   // откуда кладёт карту
gone_x = bowl_x + 120; gone_y = bowl_y + 70;   // уходит в темноту

// Состояние лягушонка
st       = "emerge";
t        = 0;
fx       = hide_x; fy = hide_y;
f_spr    = spr_frog_idle_down;
f_flip   = false;    // true — зеркально (смотрит вправо в боковых кадрах)
f_vis_h  = 0;        // сколько верхних пикселей видно (выглядывает из-за грядки)
f_alpha  = 1;
f_frame_lock = -1;   // >= 0 — стоп-кадр
hop_from = [0, 0]; hop_to = [0, 0]; hop_len = 1; hop_h = 0; hop_t = 0;
map_inst = noone;
crumbs   = [];       // {x, y, vx, vy, life}

// Звуки (если в проекте появятся — заиграют сами): сверчки фоном и шелест листвы, когда лягушонок вылезает
snd_crickets = asset_get_index("snd_night_crickets");
snd_rustle   = asset_get_index("snd_leaves_rustle");
crickets_id  = -1;
if (audio_exists(snd_crickets)) crickets_id = audio_play_sound(snd_crickets, 1, true);
