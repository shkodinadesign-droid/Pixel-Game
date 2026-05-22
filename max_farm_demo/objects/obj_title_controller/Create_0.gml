/// CREATE: Title screen controller (MAX FARM)

enum TitleState { FadeIn, Wait, FadeOut };
state = TitleState.FadeIn;

// Fade
fade_alpha     = 1;
fade_in_speed  = 0.02;
fade_out_speed = 0.03;

// Таймер / мигание
t = 0;
blink_speed = 0.08;

// Текст подсказки
press_text = "Press any key";

// Безопасный индекс джингла (если нет — будет -1)
snd_title_idx = asset_get_index("snd_title_jingle");
played_jingle = false;
