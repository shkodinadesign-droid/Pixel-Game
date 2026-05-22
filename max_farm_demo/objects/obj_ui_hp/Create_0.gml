// ===== UI HP CREATE =====
if (instance_number(obj_ui_hp) > 1) {
    instance_destroy();
    exit;
}
persistent = true;

// Плавное появление (0 → 1)
hp_alpha = 0;
