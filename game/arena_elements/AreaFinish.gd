[gd_scene load_steps=5 format=2]

[ext_resource path="res://game/ui/hud/HudGameTimer.gd" type="Script" id=1]
[ext_resource path="res://assets/theme/gravity_theme.tres" type="Theme" id=2]
[ext_resource path="res://assets/theme/fonts/menu_font.tres" type="DynamicFont" id=3]
[ext_resource path="res://assets/fonts/menu_font.tres" type="DynamicFont" id=4]

[node name="GameTimer" type="HBoxContainer"]
margin_left = -50.0
margin_right = 50.0
margin_bottom = 26.0
grow_horizontal = 2
theme = ExtResource( 2 )
custom_constants/separation = 2
alignment = 1
script = ExtResource( 1 )
__meta__ = {
"_edit_group_": true
}

[node name="Mins" type="Label" parent="."]
margin_left = 1.0
margin_right = 27.0
margin_bottom = 26.0
rect_min_size = Vector2( 26, 0 )
size_flags_vertical = 8
custom_fonts/font = ExtResource( 3 )
text = "00"
align = 2
valign = 2

[node name="Dots" type="Label" parent="."]
margin_left = 29.0
margin_right = 35.0
margin_bottom = 26.0
size_flags_horizontal = 4
size_flags_vertical = 8
custom_fonts/font = ExtResource( 4 )
text = ":"
align = 1
valign = 2

[node name="Secs" type="Label" parent="."]
margin_left = 37.0
margin_right = 63.0
margin_bottom = 26.0
grow_horizontal = 2
rect_min_size = Vector2( 26, 0 )
size_flags_vertical = 8
custom_fonts/font = ExtResource( 3 )
text = "00"
align = 1
valign = 2

[node name="Dots2" type="Label" parent="."]
margin_left = 65.0
margin_right = 71.0
margin_bottom = 26.0
size_flags_horizontal = 4
size_flags_vertical = 8
custom_fonts/font = ExtResource( 4 )
text = ":"
align = 1
valign = 2

[node name="Hunds" type="Label" parent="."]
margin_left = 73.0
margin_right = 99.0
margin_bottom = 26.0
grow_horizontal = 0
rect_min_size = Vector2( 26, 0 )
size_flags_vertical = 8
custom_fonts/font = ExtResource( 3 )
text = "00"
valign = 2
