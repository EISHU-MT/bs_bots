bs_match.register_OnMatchStart(bots.restart_bots)
bs_match.register_OnEndMatch(function()
	core.clear_objects({mode = "quick"})
end)















