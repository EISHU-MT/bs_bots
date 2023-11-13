function mobkit.get_stand_pos(thing)
	local pos = {}
	local colbox = {}
	if type(thing) == 'table' then
		pos = thing.object:get_pos()
		if thing.object:get_properties() then
			colbox = thing.object:get_properties().collisionbox
		else
			return vector.zero()
		end
	elseif type(thing) == 'userdata' then
		pos = thing:get_pos()
		if thing:get_properties() then
			colbox = thing:get_properties().collisionbox
		else
			return vector.zero()
		end
	else 
		return false
	end
	if colbox and pos then
		return mobkit.pos_shift(pos,{y=colbox[2]+0.01}), pos
	else
		return vector.zero()
	end
end

function mobkit.lq_turn2pos(self,tpos)
	local func=function(self)
		local pos = self.object:get_pos()
		if pos and tpos then
			return mobkit.turn2yaw(self,
				minetest.dir_to_yaw(vector.direction(pos,tpos)))
		else
			return false
		end
	end
	mobkit.queue_low(self,func)
end


