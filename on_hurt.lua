return function(self, puncher, _, _, _, damage)
	local puncher_team = bs.get_player_team_css(puncher)
	
	if puncher_team ~= "" then
		local from = bots.to_2d(self.object:get_pos())
		local to = bots.to_2d(puncher:get_pos())
		local offset_to = {
			x = to.x - from.x,
			y = to.y - from.y
		}
		
		local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
		self.object:set_yaw(dir)
		if puncher_team == self.team then
			bots.chat(self, "send_warning_to_teammate", Name(puncher_team))
		end
		mobkit.hurt(self, damage)
	end
	
end