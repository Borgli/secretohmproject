
--[[---------------------------------------------------------

  This file should contain variables and functions that are
   the same on both client and server.

  This file will get sent to the client - so don't add
   anything to this file that you don't want them to be
   able to see.

-----------------------------------------------------------]]

include('obj_player_extend.lua')

include('gravitygun.lua')
include('player_shd.lua')
include('animations.lua')
include('player_class/player_default.lua')
include('player_class/player_survivor.lua')
include('player_class/player_monster.lua')
include('util.lua')

GM.Name			= "Horror Escape"
GM.Author		= "Ohm"
GM.Email		   = "ohmos@ohm.ohm"
GM.Website		= "www.ohm.ohm"
GM.TeamBased	= true
GM.DevMode     = true

TEAM_SURVIVORS = 1
TEAM_MONSTERS  = 2
TEAM_SPECTATOR = 3
ACTIVE_PLAYERS = {}


--[[---------------------------------------------------------
   Name: gamemode:PlayerHurt()
   Desc: Called when a player is hurt.
-----------------------------------------------------------]]
function GM:PlayerHurt(player, attacker, healthleft, healthtaken)
end

--[[---------------------------------------------------------
   Name: gamemode:KeyPress()
   Desc: Player pressed a key (see IN enums)
-----------------------------------------------------------]]
function GM:KeyPress(player, key)
end

--[[---------------------------------------------------------
   Name: gamemode:KeyRelease()
   Desc: Player released a key (see IN enums)
-----------------------------------------------------------]]
function GM:KeyRelease(player, key)
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerConnect()
   Desc: Player has connects to the server (hasn't spawned)
-----------------------------------------------------------]]
function GM:PlayerConnect(name, address)
   if (name == "DoDraugen") then print("Rune er awesome!") end;
end

--[[---------------------------------------------------------
   Name: gamemode:PropBreak()
   Desc: Prop has been broken
-----------------------------------------------------------]]
function GM:PropBreak(attacker, prop)
end

--[[---------------------------------------------------------
   Name: gamemode:PhysgunPickup()
   Desc: Return true if player can pickup entity
-----------------------------------------------------------]]
function GM:PhysgunPickup(ply, ent)

   -- Don't pick up players
   if (ent:GetClass() == "player") then return false end

   return true
end

--[[---------------------------------------------------------
   Name: gamemode:PhysgunDrop()
   Desc: Dropped an entity
-----------------------------------------------------------]]
function GM:PhysgunDrop(ply, ent)
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage(ply, attacker)
   if (IsEntity(attacker)) then return true end
   if (attacker:IsValid() and ply:Team() == attacker:Team()) then return false
   else return true
   end
end

--[[---------------------------------------------------------
   Name: Text to show in the server browser
-----------------------------------------------------------]]
function GM:GetGameDescription()
   return self.Name
end

--[[---------------------------------------------------------
   Name: Saved
-----------------------------------------------------------]]
function GM:Saved()
end

--[[---------------------------------------------------------
   Name: Restored
-----------------------------------------------------------]]
function GM:Restored()
end

--[[---------------------------------------------------------
   Name: EntityRemoved
   Desc: Called right before an entity is removed. Note that this
   isn't going to be totally reliable on the client since the client
   only knows about entities that it has had in its PVS.
-----------------------------------------------------------]]
function GM:EntityRemoved(ent)
end

--[[---------------------------------------------------------
   Name: Tick
   Desc: Like Think except called every tick on both client and server
-----------------------------------------------------------]]
function GM:Tick()
end

--[[---------------------------------------------------------
   Name: OnEntityCreated
   Desc: Called right after the Entity has been made visible to Lua
-----------------------------------------------------------]]
function GM:OnEntityCreated(Ent)
end

--[[---------------------------------------------------------
   Name: gamemode:EntityKeyValue(ent, key, value)
   Desc: Called when an entity has a keyvalue set
		 Returning a string it will override the value
-----------------------------------------------------------]]
function GM:EntityKeyValue(ent, key, value)
end

--[[---------------------------------------------------------
   Name: gamemode:CreateTeams()
   Desc: Note - HAS to be shared.
-----------------------------------------------------------]]
function GM:CreateTeams()

   -- Don't do this if not teambased. But if it is teambased we
   -- create a few teams here as an example. If you're making a teambased
   -- gamemode you should override this function in your gamemode

   if (not GAMEMODE.TeamBased) then return end

   --TEAM_SURVIVORS = 1
   team.SetUp(TEAM_SURVIVORS, "Survivors", Color(0, 0, 255))
   team.SetSpawnPoint(TEAM_SURVIVORS, "info_player_start") -- <-- This would be info_terrorist or some entity that is in your map

   --TEAM_MONSTERS = 2
   team.SetUp(TEAM_MONSTERS, "Monsters", Color(255, 150, 0))
   team.SetSpawnPoint(TEAM_MONSTERS, "info_terrorist") -- <-- This would be info_terrorist or some entity that is in your map

   --TEAM_SPECTATORS = 3
   team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 150, 150))
   team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn") -- <-- This would be info_terrorist or some entity that is in your map
   
   --team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")

end

--[[---------------------------------------------------------
   Name: gamemode:ShouldCollide(Ent1, Ent2)
   Desc: This should always return true unless you have
		  a good reason for it not to.
-----------------------------------------------------------]]
function GM:ShouldCollide(Ent1, Ent2)

   return true

end

--[[---------------------------------------------------------
   Name: gamemode:Move
   This basically overrides the NOCLIP, PLAYERMOVE movement stuff.
   It's what actually performs the move.
   Return true to not perform any default movement actions. (completely override)
-----------------------------------------------------------]]
function GM:Move(ply, mv)

   if (drive.Move(ply, mv)) then return true end
   if (player_manager.RunClass(ply, "Move", mv)) then return true end

end

--[[---------------------------------------------------------
-- Purpose: This is called pre player movement and copies all the data necessary
--          from the player for movement. Copy from the usercmd to move.
-----------------------------------------------------------]]
function GM:SetupMove(ply, mv, cmd)

   if (drive.StartMove(ply, mv, cmd)) then return true end
   if (player_manager.RunClass(ply, "StartMove", mv, cmd)) then return true end

end

--[[---------------------------------------------------------
   Name: gamemode:FinishMove(player, movedata)
-----------------------------------------------------------]]
function GM:FinishMove(ply, mv)

   if (drive.FinishMove(ply, mv)) then return true end
   if (player_manager.RunClass(ply, "FinishMove", mv)) then return true end

end

--[[---------------------------------------------------------
   Name: gamemode:FinishMove(player, movedata)
-----------------------------------------------------------]]
function GM:VehicleMove(ply, vehicle, mv)

   --
   -- On duck toggle third person view
   --
   if (mv:KeyPressed(IN_DUCK)) then
      vehicle:SetThirdPersonMode(not vehicle:GetThirdPersonMode())
   end

   --
   -- Adjust the camera distance with the mouse wheel
   --
   local iWheel = ply:GetCurrentCommand():GetMouseWheel()
   if (iWheel ~= 0) then
      -- The distance is a multiplier
      -- Actual camera distance = (renderradius + renderradius * dist)
      -- so -1 will be zero.. clamp it there.
      local newdist = math.Clamp(vehicle:GetCameraDistance() - iWheel * 0.03 * (1.1 + vehicle:GetCameraDistance()), -1, 10)
      vehicle:SetCameraDistance(newdist)
   end

end

--[[---------------------------------------------------------
	Called after the player's think.
-----------------------------------------------------------]]
function GM:PlayerPostThink(ply)

end

--[[---------------------------------------------------------
	A player has started driving an entity
-----------------------------------------------------------]]
function GM:StartEntityDriving(ent, ply)

   drive.Start(ply, ent)

end

--[[---------------------------------------------------------
	A player has stopped driving an entity
-----------------------------------------------------------]]
function GM:EndEntityDriving(ent, ply)

   drive.End(ply, ent)

end

--[[---------------------------------------------------------
	To update the player's animation during a drive
-----------------------------------------------------------]]
function GM:PlayerDriveAnimate(ply)

end

--[[---------------------------------------------------------
	The gamemode has been reloaded
-----------------------------------------------------------]]
function GM:OnReloaded()
end

function GM:PreGamemodeLoaded()
end

function GM:OnGamemodeLoaded()
end

function GM:PostGamemodeLoaded()
end

--
-- Name: GM:OnViewModelChanged
-- Desc: Called when the player changes their weapon to another one - and their viewmodel model changes
-- Arg1: Entity|viewmodel|The viewmodel that is changing
-- Arg2: string|old|The old model
-- Arg3: string|new|The new model
-- Ret1:
--
function GM:OnViewModelChanged(vm, old, new)

   local ply = vm:GetOwner()
   if (IsValid(ply)) then
      player_manager.RunClass(ply, "ViewModelChanged", vm, old, new)
   end

end

--[[---------------------------------------------------------
	Disable properties serverside for all non-sandbox derived gamemodes.
-----------------------------------------------------------]]
function GM:CanProperty(pl, property, ent)
   return false
end
