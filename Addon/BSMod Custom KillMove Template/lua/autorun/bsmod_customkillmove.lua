
--This adds to a list of entities that can be killmovable (highlighted blue) when taking damage
--ValveBipeds by default are on this list so use this only for entities with different bone structures such as headcrabs

--Make sure the entity you're checking for in the killmove function below is added to this list, you can add as many as you want

timer.Simple(0, function()
	if killMovableEnts then
		
		--These are commented out because we won't be using them in this example, feel free to uncomment them if you want to add more non ValveBiped npcs to be killmovable
		
		--[[if !table.HasValue(killMovableEnts, "npc_strider") then
			table.insert( killMovableEnts, "npc_strider" )
		end
		if !table.HasValue(killMovableEnts, "npc_headcrab") then
			table.insert( killMovableEnts, "npc_headcrab" )
		end]]
	end
end)

--This is the hook for custom killmoves

--IMPORTANT: Make sure to change the UniqueName to something else to avoid conflicts with other custom killmove addons
hook.Add("CustomKillMoves", "UniqueName", function(ply, target, angleAround)
	
	--Setup some values for custom killmove data
	
	local plyKMModel = nil
	local targetKMModel = nil
	local animName = nil
	local plyKMPosition = nil
	local plyKMAngle = nil
	
	local kmData = {1, 2, 3, 4, 5} --We'll use this at the end of the hook
	
	plyKMModel = "models/weapons/c_limbs_template.mdl" --We set the Players killmove model to the custom one that has the animations
	
	--Use these checks for angle specific killmoves, make sure to keep the brackets when using them
	
	if (angleAround <= 45 or angleAround > 315) then
		--print("in front of target")
	elseif (angleAround > 45 and angleAround <= 135) then
		--print("left of target")
	elseif (angleAround > 135 and angleAround <= 225) then
		--print("behind target")
	elseif (angleAround > 225 and angleAround <= 315) then
		--print("right of target")
	end
	
	--For this example we'll add some custom Zombie killmoves
	
	if target:GetClass() == "npc_zombie" and ply:OnGround() and (angleAround <= 45 or angleAround > 315) then --Check if the Target is a Zombie and that the Player is on the ground
	
		targetKMModel = "models/bsmodimations_zombie_template.mdl" --Set the Targets killmove model
		
		if math.random(1, 2) == 1 then
			animName = "killmove_zombie_kick1" --Set the name of the animation that will play for both the Player and Target model
		else
			animName = "killmove_zombie_punch1"
		end
		
		--Positioning the player for different killmove animations
		
		if animName == "killmove_zombie_punch1" then
			plyKMPosition = target:GetPos() + (target:GetForward() * 70 ) --Position the player in front of the Target and x distance away
		elseif animName == "killmove_zombie_kick1" then
			plyKMPosition = target:GetPos() + (target:GetForward() * 75 )
		end
		
		kmData[1] = plyKMModel
		kmData[2] = targetKMModel
		kmData[3] = animName
		kmData[4] = plyKMPosition
		kmData[5] = plyKMAngle
		
		if animName != nil then return kmData end --Send the killmove data to the main addons killmove check function
	end
end)

--This is the hook for custom killmove effects and sounds

hook.Add("CustomKMEffects", "UniqueName", function(ply, animName, targetModel)
	
	local targetHeadBone = nil
		
	if IsValid (targetModel) then targetHeadBone = targetModel:GetHeadBone() end
	
	if animName == "killmove_zombie_punch1" then --Check the killmove animation names
		
		--Set a timer for effects, you can add more timers for more sounds
		
		timer.Simple(0.8 --[[delay]], function()
			if !IsValid(targetModel) then return end --Check if the Target still exists to avoid script errors
			
			--This function will play random sounds. for example: here are 2 sound files killmovesound1 and killmovesound2, using this function with min being 1 and max being 2, it will choose a random one of those between that range to play.
			
			PlayRandomSound(ply, 1 --[[min]], 5 --[[max]], "player/killmove/km_hit" --[[path to the sound]])
			
			if targetHeadBone != nil then
				
				--This will emit a blood effect at the target's head bone
				
				local effectdata = EffectData()
				effectdata:SetOrigin(targetModel:GetBonePosition(targetHeadBone))
				
				--You can also specify which bone you want the effect to be positioned to
				--effectdata:SetOrigin(targetModel:GetBonePosition(targetModel:LookupBone("ValveBiped.Bip01_Spine")))
				
				util.Effect("BloodImpact", effectdata)
			end
		end)
		
		--Repeat the same for different animations
		
	elseif animName == "killmove_zombie_kick1" then
		timer.Simple(0.7, function()
			if !IsValid(targetModel) then return end
			
			PlayRandomSound(ply, 1, 5, "player/killmove/km_hit")
			
			if targetHeadBone != nil then
				local effectdata = EffectData()
				effectdata:SetOrigin(targetModel:GetBonePosition(targetHeadBone))
				util.Effect("BloodImpact", effectdata)
			end
		end)
	end
end)
