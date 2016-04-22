kickafk = {}
players = {}
local CPU_saver = 0

kickafk.version = "1.0"
kickafk.first_flag = 0

local modpath = minetest.get_modpath("kickafk")

kickafk.players = tonumber(minetest.setting_get("kickafk_number_of_players")) or 10
if kickafk.players < 0 or kickafk.players > 30 then
	kickafk.players = 15
end

kickafk.timer = tonumber(minetest.setting_get('kickafk_length_of_time')) or 2000
if kickafk.timer < 0 or kickafk.timer > 1500 then
	kickafk.timer = 1500
end

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {last_pos = 0,0,}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

minetest.register_privilege("canafk",
		"Player can remain afk without being kicked")

minetest.register_globalstep(function(dtime)

	CPU_saver = CPU_saver + dtime

	if CPU_saver < kickafk.timer then
		return
	end

	CPU_saver = 0

	local players_online = 0

	-- Loop through all connected players
	for _,player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()

		-- Only continue if the player has an entry in the players table
		if players[player_name] then
		print(players[player_name].last_pos)
			players_online = players_online + 1

			if players_online >= kickafk.players then
			print("number of players is "..players_online)

				-- Kick the player if their location hasn't changed.
				local pos = player:getpos()
				local pos_hash = math.floor(pos.x) .. ',' .. math.floor(pos.z)

				if players[player_name].last_pos == pos_hash then
					if not minetest.check_player_privs(player_name,"canafk") == true then
						minetest.kick_player(player_name, "Network Timeout")
					end
				end
				
				-- Record the players location
				if players[player_name].last_pos ~= pos_hash then
					players[player_name].last_pos = pos_hash
				end
			end
		end
	end
end)
