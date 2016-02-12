
-- movement utils

function HasChain()
	if type(Chain) ~= 'table' then
		return false
	else
		return #Chain > 0
	end
end
	
function SlowDuckJump()
	if DeltaTicks(SlowJumpTime) < SLOW_JUMP_PERIOD then
		return
	end
	
	if not IsOnGround() then
		return
	end
	
	DuckJump()
	
	SlowJumpTime = Ticks()
end

function UpdateScenario()
	Scenario = ScenarioType.Walking
	
	if CanCollecting then
		Scenario = ScenarioType.Collecting
		return
	end
	
	if IsEndOfRound then
		return
	end
	
	if (GetGameDir() == 'cstrike') or (GetGameDir() == 'czero') then
		if GetPlayerTeam(GetClientIndex()) == 'TERRORIST' then
			
			if IsWeaponExists(CS_WEAPON_C4) then
				Scenario = ScenarioType.PlantingBomb
			elseif IsBombDropped then
				Scenario = ScenarioType.SearchingBomb 
			end
		
		elseif GetPlayerTeam(GetClientIndex()) == 'CT' then
			
			if IsBombPlanted then
				Scenario = ScenarioType.DefusingBomb
			end
			
		end
	elseif GetGameDir() == 'valve' then
		--Scenario = ScenarioType.SearchingItems
	end
end

function ResetScenarion()
	Scenario = ScenarioType.None
end

-- weapon utils	
	
function FindCurrentWeapon()
	CurrentWeapon = GetWeaponByAbsoluteIndex(GetWeaponAbsoluteIndex())

	if (LastKnownWeapon ~= CurrentWeapon) and (CurrentWeapon ~= 0) and (LastKnownWeapon ~= 0) then
		print('choosed: ' .. GetWeaponNameEx(CurrentWeapon))
	end

	LastKnownWeapon = CurrentWeapon
end

function FindHeaviestWeaponInSlot(ASlot)
	local Weapon = nil
	local Weight = -1
	
	-- TODO: add ammo checking
	
	for I = 0, GetWeaponsCount() - 1 do
		if IsWeaponExists(GetWeaponIndex(I)) then
			if GetWeaponSlotID(I) == ASlot then
				if GetWeaponWeight(I) > Weight then
					Weapon = I
					Weight = GetWeaponWeight(I)
				end
			end
		end
	end
	
	return Weapon
end

function FindHeaviestWeapon()
	local Weapon = nil
	local Weight = -1
	
	for I = 0, GetWeaponsCount() - 1 do
		if IsWeaponExists(GetWeaponIndex(I)) then
			if GetWeaponWeight(I) > Weight then
				Weapon = I
				Weight = GetWeaponWeight(I)
			end
		end
	end
	
	return Weapon
end

function FindHeaviestUsableWeapon(IsInstant)
	local Weapon = nil
	local Weight = -1
	
	for I = 0, GetWeaponsCount() - 1 do
		if IsWeaponExists(GetWeaponIndex(I)) then
			if CanUseWeapon(I, IsInstant) then
				if GetWeaponWeight(I) > Weight then
					Weapon = I
					Weight = GetWeaponWeight(I)
				end
			end
		end
	end
	
	return Weapon
end

function ChooseWeapon(AWeapon)
	if not IsSlowThink then
		return
	end
	
	if AWeapon == nil then
		return
	end
	
	if AWeapon == CurrentWeapon then
		return
	end
	
	ExecuteCommand(GetWeaponName(AWeapon))
end

function GetWeaponClip(AWeapon)
	if not HasWeaponData(GetWeaponIndex(AWeapon)) then
		return 0
	end
	
	return GetWeaponDataField(GetWeaponIndex(AWeapon), WeaponDataField.Clip)
end

function HasWeaponClip(AWeapon)
	return GetWeaponClip(AWeapon) > 0
end

function GetWeaponPrimaryAmmo(AWeapon) 
	return GetAmmo(GetWeaponPrimaryAmmoID(AWeapon))
end

function HasWeaponPrimaryAmmo(AWeapon)
	return GetWeaponPrimaryAmmo(AWeapon) > 0
end

function GetWeaponSecondaryAmmo(AWeapon)
	return GetAmmo(GetWeaponSecondaryAmmoID(AWeapon))
end

function HasWeaponSeconadryAmmo(AWeapon)
	return GetWeaponSecondaryAmmo(AWeapon) > 0
end

function CanUseWeapon(AWeapon, IsInstant)
	if AWeapon == nil then
		return false
	end
	
	local Clip = GetWeaponClip(AWeapon)
	local PrimaryAmmo = GetWeaponPrimaryAmmo(AWeapon)
	local SecondaryAmmo = GetWeaponSecondaryAmmo(AWeapon)
	
	if Clip ~= WEAPON_NOCLIP then -- weapon can be reloaded
		if IsInstant then
			return Clip > 0
		else
			return Clip + PrimaryAmmo + SecondaryAmmo > 0
		end
	else
		return PrimaryAmmo > 0
	end
end

function GetWeaponMaxClip(AWeapon)
	if (GetGameDir() == 'cstrike') or (GetGameDir() == 'czero') then
		return CSWeapons[GetWeaponIndex(AWeapon)].MaxClip
	elseif GetGameDir() == 'valve' then
		return HLWeapons[GetWeaponIndex(AWeapon)].MaxClip
	else
		print 'GetWeaponMaxClip(AWeapon) does not support this game modification'
		return nil
	end
end

function GetWeaponWeight(AWeapon)
	if (GetGameDir() == 'cstrike') or (GetGameDir() == 'czero') then
		return CSWeapons[GetWeaponIndex(AWeapon)].Weight
	elseif GetGameDir() == 'valve' then
		return HLWeapons[GetWeaponIndex(AWeapon)].Weight
	else
		print 'GetWeaponWeight(AWeapon) does not support this game modification'
		return nil
	end	
end

function IsWeaponFullyLoaded(AWeapon)
	if AWeapon == nil then
		return true
	end
 
	local Clip = GetWeaponClip(AWeapon)
	
	if Clip == WEAPON_NOCLIP then
		return true
	end
	
	if not HasWeaponPrimaryAmmo(AWeapon) then
		return true
	end

	return Clip >= GetWeaponMaxClip(AWeapon)
end

function IsWeaponFullPrimaryAmmo(AWeapon)
	return GetWeaponPrimaryAmmo(AWeapon) >= GetWeaponPrimaryAmmoMaxAmount(AWeapon)
end

function IsWeaponFullPrimaryAmmoAbs(AIndex)
	return IsWeaponFullPrimaryAmmo(GetWeaponByAbsoluteIndex(AIndex))
end

function IsWeaponFullSecondaryAmmo(AWeapon)
	return GetWeaponSecondaryAmmo(AWeapon) >= GetWeaponSecondaryAmmoMaxAmount(AWeapon)
end

function IsWeaponFullSecondaryAmmoAbs(AIndex)
	return IsWeaponFullSecondaryAmmo(GetWeaponByAbsoluteIndex(AIndex))
end

function NeedReloadWeapon(AWeapon)
	return not IsWeaponFullyLoaded(AWeapon)
end

function CanReload()
	-- TODO: write something here
	
	return true
end

-- attack

function IsAttacking()
	return DeltaTicks(LastAttackTime) < 500 -- fix
end

-- common utils

function Behavior.Randomize()
	Behavior.MoveWhenShooting = Chance(50)
	Behavior.CrouchWhenShooting = Chance(50)
	Behavior.MoveWhenReloading = Chance(50)
	Behavior.AimWhenReloading = Chance(50)
	Behavior.AlternativeKnifeAttack = Chance(50)
	Behavior.ReloadDelay = math.random(1000, 10000)
	Behavior.DuckWhenPlantingBomb = Chance(50)
	Behavior.DuckWhenDefusingBomb = Chance(50)
	Behavior.Psycho = Chance(5)
end

function MyHeight()
	if IsCrouching() then
		return HUMAN_HEIGHT_DUCK
	else
		return HUMAN_HEIGHT_STAND
	end
end

function IsEnemy(player_index)
	if IsTeamPlay() --[[and not FriendlyFire]] then
		if (GetGameDir() == 'tfc') or (GetGameDir() == 'dod') then
			-- dod & tfc are not using absolute team names, we need to compare team indexes from entities array
		
			local T1 = GetEntityTeam(GetClientIndex() + 1)
			local T2 = GetEntityTeam(player_index + 1)
			
			return T1 ~= T2
		else 		
			-- we can compare team names from players array for all other mods
		
			local T1 = GetPlayerTeam(GetClientIndex())
			local T2 = GetPlayerTeam(player_index)
			
			return T1 ~= T2
		end
	else
		if GetGameDir() == 'svencoop' then
			return false
		else
			return true
		end
	end
end

function IsPlayerPriority(APlayer)
	return APlayer < GetClientIndex()
end

function FindEnemiesAndFriends()
	NearestEnemy = nil;
	NearestLeaderEnemy = nil;
	EnemiesNearCount = 0;

	NearestFriend = nil;
	NearestLeaderFriend = nil;
	FriendsNearCount = 0;
	
	NearestPlayer = nil
	NearestLeaderPlayer = nil
	PlayersNearCount = 0
	
	local EnemyDistance = MAX_UNITS
	local EnemyKills = 0

	local FriendDistance = MAX_UNITS
	local FriendKills = 0
	
	local PlayerDistance = MAX_UNITS
	local PlayerKills = 0


	NearestVisibleEnemy = nil;
	NearestVisibleLeaderEnemy = nil;
	VisibleEnemiesNearCount = 0;

	NearestVisibleFriend = nil;
	NearestVisibleLeaderFriend = nil;
	VisibleFriendsNearCount = 0;
	
	NearestVisiblePlayer = nil
	NearestVisibleLeaderPlayer = nil
	VisiblePlayersNearCount = 0
	
	local VisibleEnemyDistance = MAX_UNITS
	local VisibleEnemyKills = 0

	local VisibleFriendDistance = MAX_UNITS
	local VisibleFriendKills = 0
	
	local VisiblePlayerDistance = MAX_UNITS
	local VisiblePlayerKills = 0		
	
	
	for I = 1, GetPlayersCount() do
		if I ~= GetClientIndex() + 1 then
			if --[[IsEntityActive(I)]] GetPlayerOrigin(I - 1) ~= 0 then -- player may be on radar
				if IsPlayerAlive(I - 1) then
					
					PlayersNearCount = PlayersNearCount + 1
					
					if GetDistance(I) < PlayerDistance then
						PlayerDistance = GetDistance(I)
						NearestPlayer = I
					end
						
					if GetPlayerKills(I - 1) > PlayerKills then
						PlayerKills = GetPlayerKills(I - 1)
						NearestLeaderPlayer = I
					end

					if IsEnemy(I - 1) then
						EnemiesNearCount = EnemiesNearCount + 1
					
						if GetDistance(I) < EnemyDistance then
							EnemyDistance = GetDistance(I)
							NearestEnemy = I
						end
					
						if GetPlayerKills(I - 1) > EnemyKills then
							EnemyKills = GetPlayerKills(I - 1)
							NearestLeaderEnemy = I
						end					
					else
						FriendsNearCount = FriendsNearCount + 1
					
						if GetDistance(I) < FriendDistance then
							FriendDistance = GetDistance(I)
							NearestFriend = I
						end
					
						if GetPlayerKills(I - 1) > FriendKills then
							FriendKills = GetPlayerKills(I - 1)
							NearestLeaderFriend = I
						end	
					end
					
					if HasWorld() then
						if IsVisible(I)then
							VisiblePlayersNearCount = VisiblePlayersNearCount + 1
							
							if GetDistance(I) < VisiblePlayerDistance then
								VisiblePlayerDistance = GetDistance(I)
								NearestVisiblePlayer = I
							end
								
							if GetPlayerKills(I - 1) > VisiblePlayerKills then
								VisiblePlayerKills = GetPlayerKills(I - 1)
								NearestVisibleLeaderPlayer = I
							end

							if IsEnemy(I - 1) then
								VisibleEnemiesNearCount = VisibleEnemiesNearCount + 1
							
								if GetDistance(I) < VisibleEnemyDistance then
									VisibleEnemyDistance = GetDistance(I)
									NearestVisibleEnemy = I
								end
							
								if GetPlayerKills(I - 1) > VisibleEnemyKills then
									VisibleEnemyKills = GetPlayerKills(I - 1)
									NearestVisibleLeaderEnemy = I
								end					
							else
								VisibleFriendsNearCount = VisibleFriendsNearCount + 1
							
								if GetDistance(I) < VisibleFriendDistance then
									VisibleFriendDistance = GetDistance(I)
									NearestVisibleFriend = I
								end
							
								if GetPlayerKills(I - 1) > VisibleFriendKills then
									VisibleFriendKills = GetPlayerKills(I - 1)
									NearestVisibleLeaderFriend = I
								end	
							end
						end
					end
				end
			end			
		end
	end
	
	HasEnemiesNear = EnemiesNearCount > 0
	HasFriendsNear = FriendsNearCount > 0
	HasPlayersNear = PlayersNearCount > 0
	
	HasVisibleEnemiesNear = VisibleEnemiesNearCount > 0
	HasVisibleFriendsNear = VisibleFriendsNearCount > 0
	HasVisiblePlayersNear = VisiblePlayersNearCount > 0	
end

function FindVictim()
	if not HasWorld() then
		return
	end
	
	Victim = NearestVisibleEnemy
	
	HasVictim = Victim ~= nil
end

function FindStatusIconByName(AName)
	for I = 0, GetStatusIconsCount() - 1 do
		if GetStatusIconName(I) == AName then
			return I
		end
	end
		
	return nil
end

function FindResourceByIndex(AIndex, AType)
	for I = 0, GetResourcesCount() - 1 do
		if GetResourceType(I) == AType then
			if GetResourceIndex(I) == AIndex then
				return I
			end
		end
	end
	
	return nil
end

function FindActiveEntityByModelName(AModelName)
	for I = 0, GetEntitiesCount() - 1 do
		if IsEntityActive(I) then
			local R = FindResourceByIndex(GetEntityModelIndex(I), RT_MODEL)
			
			if R ~= nil then
				if string.sub(GetResourceName(R), 1, string.len(AModelName)) == AModelName then
					return I
				end
			end
		end
	end
	
	return nil
end

function GetModelGabaritesCenter(AModel)
	local MinS = Vec3.New(GetWorldModelMinS(AModel))
	local MaxS = Vec3.New(GetWorldModelMaxS(AModel))
	
	local D = Vec3Line.New(MinS.X, MinS.Y, MinS.Z, MaxS.X, MaxS.Y, MaxS.Z)
	
	return D:Center()
end

function GetWalkSpeed()
	if (GetGameDir() == 'cstrike') or (GetGameDir() == 'czero') then
		return 130
	else
		print('GetWalkSpeed: unknown mod')
	end
end

function HasLongJump()
	return string.find(GetClientPhysInfo(), '\\slj\\1') ~= nil
end