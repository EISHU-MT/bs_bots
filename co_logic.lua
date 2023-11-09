function bots.co_logic(self, mv)
	if mv.collides then
		for _, collisions in pairs(mv.collisions) do
			if collisions.type == "object" then
				local obj = collisions.object
				if Name(obj) then
					local player_team = bs.get_player_team_css(obj)
					if player_team ~= "" and player_team ~= bots.data[self.bot_name].team then
						if bots.path_finder_running[self.bot_name] then
							bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].walk_mine, bots.bots_animations[self.bot_name].anispeed, 0)
						else
							bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, bots.bots_animations[self.bot_name].anispeed, 0)
						end
						collisions.object:punch(self.object, nil, {damage_groups = {fleshy = 5}}, nil)
						bots.in_hand_weapon[self.bot_name] = "default:sword_steel"
						if bots.data[self.bot_name].wield_item_obj then
							bots.data[self.bot_name].wield_item_obj:set_properties({
								textures = {"default:sword_steel"},
								visual_size = {x=0.25, y=0.25},
							})
						end
						
						local from = bots.to_2d(self.object:get_pos())
						local to = bots.to_2d(obj:get_pos())
						local offset_to = {
							x = to.x - from.x,
							y = to.y - from.y
						}
						local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
						
						self.object:set_yaw(dir)
					end
				end
			end
		end
	end
	if bots.path_finder_running[self.bot_name] then
		bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].walk, bots.bots_animations[self.bot_name].anispeed, 0)
	else
		bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].stand, bots.bots_animations[self.bot_name].anispeed, 0)
	end
end