# Pixel-Game — разбор утверждённой карты на ассеты

**Мастер-кадр:** 1672×941px. Этот PNG — художественный эталон, НЕ готовая GameMaker Tile Map.
**Сетка разработки:** 32×32px для покрытия/тайлов. Спрайты отдельных объектов могут быть крупнее.
**Принцип:** сначала проверять существующие одобренные игровые PNG и переиспользовать их, а не генерировать новые версии.
**Пиксели:** сохранять оригинальные формы, композицию и цвет; вычищать только края при разрезании, без изменения дизайна.
**Примечание о масштабе:** 1672×941 не кратно 32, поэтому скрин нельзя разрезать прямоугольными ячейками и импортировать как корректный 32px тайлсет. Тайлы нужно отрисовать бесшовно в игровой сетке с цветами из эталона.
**Состояние:** `verify_reuse` означает "проверить, что уже есть в актуальной ветке", а не "точно отсутствует".

## Порядок партий

### 00 — REFERENCE
- **MASTER_LOCK** · `MASTER_REFERENCE_APPROVED_UNCHANGED.png` · `reference` · Original composition; do not edit. · `fixed`
- **PALETTE_LOCK** · `PALETTE_MASTER_SAMPLES.gpl` · `palette` · Color source reference, verify samples visually before final indexed art. · `sampled`

### 01 — GROUND
- **grass_base** · `tls_village_ground_32.png` · `tileset` · Plain olive grass, primary seamless 32x32. · `create`
- **grass_variants** · `tls_village_ground_32.png` · `tileset` · 2-3 VERY sparse variants, no scattered noise. · `create`
- **ground_sparse_grass** · `spr_village_ground_tufts.png` · `sprite` · Tiny grass clumps; decoration not collision. · `create`

### 02 — DIRT_ROADS
- **sand_center** · `tls_village_dirt_32.png` · `tileset` · Warm sandy road center, continuous repeat. · `create`
- **sand_straights** · `tls_village_dirt_32.png` · `tileset` · Four directions of road/grass edge. · `create`
- **sand_outer_corners** · `tls_village_dirt_32.png` · `tileset` · Four outer rounded corners. · `create`
- **sand_inner_corners** · `tls_village_dirt_32.png` · `tileset` · Four concave corners. · `create`
- **sand_tjunction_cross** · `tls_village_dirt_32.png` · `tileset` · T, cross & narrow-path connections matching approved geometry. · `create`

### 03 — PLAZA_PAVING
- **pave_base** · `tls_village_plaza_32.png` · `tileset` · One 32x32 light square stone; thin soft joint. · `create`
- **pave_variants** · `tls_village_plaza_32.png` · `tileset` · 2-3 low-contrast texture/color variants only. · `create`
- **pave_central_ring** · `tls_village_plaza_circle_32.png` · `tileset` · Circular warm red stone ring: modular pieces. · `create`
- **pave_central_bed** · `spr_village_circle_flowerbed.png` · `sprite` · Round planted flowerbed located at plaza center. · `create`

### 04 — CURBS
- **curb_straights** · `tls_village_curbs_32.png` · `tileset` · Edges all four orientations: beige, not white. · `create`
- **curb_outer_corners** · `tls_village_curbs_32.png` · `tileset` · 4 soft rounded outer corners. · `create`
- **curb_inner_corners** · `tls_village_curbs_32.png` · `tileset` · 4 inner corners, no seams. · `create`
- **curb_grass** · `tls_village_curbs_32.png` · `tileset` · Curb transitions against grass. · `create`
- **curb_sand** · `tls_village_curbs_32.png` · `tileset` · Curb transitions against dirt path. · `create`

### 05 — RIVER_BRIDGE
- **river_water_base** · `tls_village_river_32.png` · `tileset` · Seamless turquoise water center. · `create`
- **river_water_sparkles** · `tls_village_river_32.png` · `tileset` · Few simple ripples, quiet variation. · `create`
- **river_bank_straights** · `tls_village_river_32.png` · `tileset` · Bank all four orientations, matching olive grass. · `create`
- **river_bank_corners** · `tls_village_river_32.png` · `tileset` · Four convex and four concave bank corners. · `create`
- **river_stones_plants** · `spr_village_river_decor.png` · `sprite` · Stones, reeds, lilypads, optional transparent overlays. · `create`
- **river_bridge** · `spr_village_wood_bridge.png` · `sprite` · Wood bridge across river, modular if path width changes. · `create`
- **river_bridge_edges** · `tls_village_bridge_32.png` · `tileset` · Bridge start/middle/end if modularization is needed. · `create`

### 06 — TREES
- **tree_oak** · `spr_village_oak.png` · `sprite` · Largest broad deciduous tree from master, separate alpha. · `verify_reuse`
- **tree_deciduous** · `spr_village_deciduous.png` · `sprite` · Medium broadleaf tree. · `verify_reuse`
- **tree_pine** · `spr_village_pine.png` · `sprite` · Tall pine, master olive palette. · `verify_reuse`
- **tree_pine_small** · `spr_village_pine_small.png` · `sprite` · Smaller pine variant. · `verify_reuse`
- **tree_trunk_colliders** · `obj_village_tree_*.yy` · `object` · Collision only by trunks; not leaf crowns. · `verify_reuse`

### 07 — BUSHES_HEDGES
- **bush_small** · `spr_village_bush_small.png` · `sprite` · Small olive bush. · `verify_reuse`
- **bush_medium** · `spr_village_bush_medium.png` · `sprite` · Medium rounded bush. · `verify_reuse`
- **bush_cluster** · `spr_village_bush_cluster.png` · `sprite` · One simple 2-3 bush group. · `create`
- **hedge_modular** · `tls_village_hedge_32.png` · `tileset` · Long/short/corners/endcap coherent olive low detail. · `verify_reuse`

### 08 — FLOWERS_PLANTS
- **flower_white** · `spr_village_flower_white.png` · `sprite` · A few white daisy pixels; isolated. · `create`
- **flower_yellow** · `spr_village_flower_yellow.png` · `sprite` · Few yellow flowers; isolated. · `create`
- **flower_purple** · `spr_village_lavender.png` · `sprite` · Purple lavender mini stalk. · `create`
- **flowerbed_long** · `spr_village_flowerbed_long.png` · `sprite` · Long wood planter matching master. · `create`
- **flowerbed_small** · `spr_village_flowerbed_small.png` · `sprite` · Small wooden flower box. · `create`
- **flower_pot** · `spr_village_flower_pot.png` · `sprite` · Small terracotta/wood pot. · `create`

### 09 — BUILDINGS
- **house_maggie** · `spr_house_maggie.png` · `sprite` · Upper left by river; grey roof, sleeping grey cat. · `verify_reuse`
- **cat_on_maggie_roof** · `spr_cat_sleep_roof.png` · `sprite` · Optional independent layer to animate; no duplicate cat. · `optional`
- **house_justin** · `spr_house_justin.png` · `sprite` · Lower left; red roof, laundry, firewood. · `verify_reuse`
- **store_joshua** · `spr_joshua_shop.png` · `sprite` · Center, GENERAL STORE, preserve exact form. · `verify_reuse`
- **butcher_ivan** · `spr_ivan_butcher.png` · `sprite` · Right, red/cream awning and meat display. · `verify_reuse`
- **cart_jack** · `spr_jack_wagon.png` · `sprite` · Lower center-right, cart without horse. · `verify_reuse`

### 10 — PROPS
- **phone_booth** · `spr_village_phone_booth.png` · `sprite` · Red phone booth on right plaza. · `verify_reuse`
- **bench** · `spr_village_bench.png` · `sprite` · Wood bench, dark steel ends. · `verify_reuse`
- **lantern_street** · `spr_village_streetlamp.png` · `sprite` · Warm yellow glass, dark upright post. · `verify_reuse`
- **bulletin_board** · `spr_village_noticeboard.png` · `sprite` · Timber stand with two notices. · `verify_reuse`
- **forest_sign** · `spr_village_forest_sign.png` · `sprite` · Top-right direction sign, forest path. · `verify_reuse`
- **wood_fence** · `tls_village_wood_fence_32.png` · `tileset` · Posts and horizontal rails, modular. · `verify_reuse`
- **wood_barrel** · `spr_village_barrel.png` · `sprite` · Small wood barrel; no duplicated scattered barrels. · `verify_reuse`
- **wood_crates** · `spr_village_crate.png` · `sprite` · Wood crate simple compact. · `verify_reuse`
- **laundry** · `spr_village_laundry.png` · `sprite` · Simple line and hanging white sheet by Justin. · `verify_reuse`
- **roof_shadows** · `spr_village_building_shadow.png` · `sprite` · Only if needed to fit background lighting; not mandatory. · `optional`

### 11 — ASSEMBLY_QA
- **map_assembly** · `rm_village` · `room` · Assemble using approved geography, preserve manual placement and routes. · `integration`
- **collisions** · `rm_village` · `room` · Accessibility of doors, forest exit, bridge and stalls. · `integration`
- **comparison** · `pixel_diff_visual_report.png` · `qa` · Side-by-side master vs actual GameMaker screenshot. · `integration`

## Правила для Claude Code
1. Сначала проверить актуальные игровые ресурсы и незакоммиченные правки. Ничего в Git не объединять без согласования.
2. Не брать целиком обрезки карты как спрайты: они содержат фон, соседние объекты и чужие тени. `REFERENCE_CROPS_NOT_SPRITES` — только для сверки.
3. Генерировать/рисовать только одну партию за раз, сохранять каждую версию и показывать в игровом масштабе 1:1.
4. PNG элементов — прозрачный фон, корректный origin у земли/основания. Изображения зданий — крупные отдельные спрайты. Дом НЕ резать на тайлы, если в демке он статичный.
5. Тайлы дороги, плитки, речки и бордюров должны иметь 32×32 px, точные стыки, все прямые и угловые варианты. Без фильтрации и сглаживания.
6. Для деревьев коллизия только у основания ствола. Декоративные цветы — проходимые. У зданий отдельные маски входа и препятствий.
7. Не изменять дом/входы/переход в лес и координаты объектов, которые автор вручную поправила, без отдельного запроса.
8. Значки ? на мастер-карте — UI/игровые маркеры, не встраивать их в рисунок зданий или декора.
9. Завершённая партия должна содержать прозрачные PNG и/или тайлсет PNG, CSV размеров/имён, PNG-демо 1:1 и краткую карту использования.
10. Тестировать совместимость с текущими Max (32×48 px), дорогами, дождём/тенью и существующими игровыми взаимодействиями.

## Предлагаемая последовательность в работе
**Начать с 01–04 (трава, песок, площадь, бордюры).** После их проверки — 05 речка/мост. Затем 06–08 природа. Затем 09 здания и 10 декор, переиспользуя существующие ресурсы. Финал — 11 сборка и QA.
Кадр-эталон не заменяет реально созданные тайлы; сборка в GameMaker будет отдельным этапом.
