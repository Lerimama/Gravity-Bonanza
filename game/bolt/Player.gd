[gd_scene load_steps=6 format=2]

[ext_resource path="res://assets/tilesets/tileset_arena_elements.png" type="Texture" id=1]
[ext_resource path="res://assets/sound/sfx/burst/burst_cocking_short.wav" type="AudioStream" id=2]
[ext_resource path="res://game/levels/CheckpointLine.gd" type="Script" id=3]

[sub_resource type="AtlasTexture" id=515]
atlas = ExtResource( 1 )
region = Rect2( 32, 16, 8, 8 )

[sub_resource type="RectangleShape2D" id=514]
extents = Vector2( 72, 4 )

[node name="Checkpoint" type="Area2D"]
position = Vector2( 0, 8 )
monitorable = false
script = ExtResource( 3 )

[node name="Sounds" type="Node" parent="."]

[node name="Nitro" type="AudioStreamPlayer" parent="Sounds"]
stream = ExtResource( 2 )
volume_db = -15.0
bus = "GameSfx"

[node name="Sprite" type="Sprite" parent="."]
position = Vector2( 4, 4 )
texture = SubResource( 515 )

[node name="Sprite2" type="Sprite" parent="."]
position = Vector2( 12, 4 )
texture = SubResource( 515 )

[node name="Sprite3" type="Sprite" parent="."]
position = Vector2( 20, 4 )
texture = SubResource( 515 )

[node name="Sprite4" type="Sprite" parent="."]
position = Vector2( 28, 4 )
texture = SubResource( 515 )

[node name="Sprite5" type="Sprite" parent="."]
position = Vector2( 36, 4 )
texture = SubResource( 515 )

[node name="Sprite6" type="Sprite" parent="."]
position = Vector2( 44, 4 )
texture = SubResource( 515 )

[node name="Sprite7" type="Sprite" parent="."]
position = Vector2( 52, 4 )
texture = SubResource( 515 )

[node name="Sprite8" type="Sprite" parent="."]
position = Vector2( 60, 4 )
texture = SubResource( 515 )

[node name="Sprite9" type="Sprite" parent="."]
position = Vector2( 68, 4 )
texture = SubResource( 515 )

[node name="Sprite10" type="Sprite" parent="."]
position = Vector2( 76, 4 )
texture = SubResource( 515 )

[node name="Sprite11" type="Sprite" parent="."]
position = Vector2( 84, 4 )
texture = SubResource( 515 )

[node name="Sprite12" type="Sprite" parent="."]
position = Vector2( 92, 4 )
texture = SubResource( 515 )

[node name="Sprite13" type="Sprite" parent="."]
position = Vector2( 100, 4 )
texture = SubResource( 515 )

[node name="Sprite14" type="Sprite" parent="."]
position = Vector2( 108, 4 )
texture = SubResource( 515 )

[node name="Sprite15" type="Sprite" parent="."]
position = Vector2( 116, 4 )
texture = SubResource( 515 )

[node name="Sprite16" type="Sprite" parent="."]
position = Vector2( 124, 4 )
texture = SubResource( 515 )

[node name="Sprite17" type="Sprite" parent="."]
position = Vector2( 132, 4 )
texture = SubResource( 515 )

[node name="Sprite18" type="Sprite" parent="."]
position = Vector2( 140, 4 )
texture = SubResource( 515 )

[node name="CollisionPolygon2D" type="CollisionShape2D" parent="."]
position = Vector2( 72, 4 )
shape = SubResource( 514 )

[connection signal="body_entered" from="." to="." method="_on_Checkpoint_body_entered"]
[connection signal="body_exited" from="." to="." method="_on_Checkpoint_body_exited"]
