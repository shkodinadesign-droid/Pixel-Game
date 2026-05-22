/// --- СТАДИИ СПЛЭША ---
enum SplashState { FadeIn, Wait, FadeOut };
state = SplashState.FadeIn;

/// --- ПАРАМЕТРЫ FADE ---
fade_alpha     = 1;      // 1 = чёрный экран, 0 = логотип полностью виден
fade_in_speed  = 0.03;
fade_out_speed = 0.03;

/// --- СКОЛЬКО ЛОГО ВИСИТ ---
wait_time = 120; // 2 секунды при 60 FPS
t = 0;

/// --- МОЖНО ЛИ ПРОПУСТИТЬ ---
allow_skip = true;

/// --- ТОЛЬКО КОМНАТА, БЕЗ СПРАЙТА ---
room_intro_idx = asset_get_index("room_intro");
