--[[
Functions explained in a nutshell:

ATTACK FUNCTIONS
kbAlertTOGGLE(true) --Make sure this code is added to the first time you use the alert function to add it to the game scene, otherwise nothing will appear.
kbAttackTOGGLE(true) --Make sure this code is added to the first time you use the attack function to add it to the game scene, otherwise nothing will appear.

Basically in order to see it, you have to first add it to the scene.
If the condition is true, then the thing is added. If false, it is removed.

kbAttack(prepare,sound)
'prepare' if false, plays the prepare animation. If true, the sawblade attacks and checks to see if BF is dodging. If he isn't, he dies.
'sound' an optional string which allows you to play a custom sound for the sawblade attack. This sound only plays when attacking, however. Make sure this sound is in the the QT week sounds folder!

kbAttackAlert(true/false)
kbAttackAlertDouble(true/false)
These functions are responsible for playing the alert animation + playing the sound.
The 'true/false' is just there because for some reason without it, it just causes the game to crash? It doesn't change anything if true or false.

Because dodging is timing based and not actually synced to BPM, you may find yourself not being fast enough to keep up with sawblades. These functions allow you to directly manipulate the timing windows for sawblades.
dodgeTimingOverride(newValue)
dodgeCooldownOverride(newValue)

Default values:
timing   = 0.22625
cooldown = 0.1135

Recommended values for double sawblades in Termination:
timing   = 0.15
cooldown = 0.1


PINCER FUNCTIONS
PincerIDs (Note that pincers only work on BF's side with the exception of pincer5 which is a special case used in the screenshaking section in Termination):
1 = left arrow 	['pincer1']
2 = down arrow	['pincer2']
3 = up arrow	['pincer3']
4 = right arrow	['pincer4']

5 = opponent left arrow (untested and unstable, may or may not cause a crash or unexpected behaviour)


kbPincerPrepare(pincerID,goAway)
'pincerID' refers to which lane you want the summon the pincer on.
'goAway' determines whether or not the pincer is being prepared/added, or leaving/being removed. False=Enter, True=Leave.

kbPincerGrab(pincerID)
Function which changes a pincer's graphic to be closed.
The pincer automatically lets go when leaving (kbPincerPrepare(pincerID,True))

If you want to reference a pincer, you can actually do this using the predefined labels assigned to each pincerID (see pincerID's above)
So, if you want to move notes around just like in Termination, you would want to tween the note to a certain position, then copy and paste the same code but instead referencing the pincer instead of the note.
Example from Termination in beatHit:

if curBeat == 320 then
	kbPincerPrepare(3,false) 						--Prepares pincer3 (up arrow pincer).
elseif curBeat == 322 then
	kbPincerGrab(3)									--Updates appearance to make it look like it is grabbing.
	if downscroll==0 then							--When moving notes around, it is important to make sure it works for both upscroll and downscroll!
		tweenPos('pincer3', x6, y6+60, 0.25, done)	--tweenPos basically means "move this thing to here in this time". So we move the pincer down in 0.25 seconds.
		tweenPos(6, x6, y6+60, 0.25, done)			--tweenPos basically means "move this thing to here in this time". So here, we move the note down in 0.25 seconds.
	else
		tweenPos('pincer3', x6, y6-60, 0.25, done)	--Same as above, but instead moving it up because the player is using downscroll!
		tweenPos(6, x6, y6-60, 0.25, done)
	end
elseif curBeat == 324 then
	kbPincerPrepare(3,true)							--pincer3 is then animated to move offscreen and is removed from the game scene until it is brought back again.
	
You can look at the modchart code for Termination for a better look at how to use the pincers.
The example below should be good enough to show how you these functions are used, along side with how the double sawblade is done.
--]]

-- Variable definition:
local x4,x5,x6,x7,y4,y5,y6,y7
--These variables are for saving the x and y position of the arrows so you can easily return them back to their original positions whenever.

function start(song)
	-- Initialization
	dodgeTimingOverride(0.3)
	dodgeCooldownOverride(0.175)
		
		
	x4 = getActorX(4)
	x5 = getActorX(5)
	x6 = getActorX(6)
	x7 = getActorX(7)
	
	y7 = getActorY(7)
	y6 = getActorY(6)
	y5 = getActorY(5)
	y4 = getActorY(4)	
end

function update(elapsed)
	--Funny modchart moment
    if difficulty == 2 and curStep > 400 then
        local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
    end
end

function beatHit(beat) -- do nothing
	
end

function stepHit(step) -- do nothing
	--Example code for sawblades and pincers
	
	if curStep == 64 then
		kbAttackTOGGLE(true)
		kbAlertTOGGLE(true)
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 68 then
		kbAttackAlert(false)
	elseif curStep == 72 then
		kbAttack(true)		--Dodge check!
		
	elseif curStep == 80 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 84 then
		kbAttackAlert(false)
	elseif curStep == 88 then
		kbAttack(true)		--Dodge check!
		
	--Example double sawblade!
	elseif curStep == 128 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 132 then
		kbAttackAlertDouble(false)
	elseif curStep == 136 then
		kbAttack(true, "old/attack_alt01")		--Dodge check!
	elseif curStep == 139 then
		kbAttack(false) 	--Prepares the sawblade again
	elseif curStep == 140 then
		kbAttack(true, "old/attack_alt02")		--Dodge check!
	
	elseif curStep == 144 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 148 then
		kbAttackAlertDouble(false)
	elseif curStep == 152 then
		kbAttack(true, "old/attack_alt01")		--Dodge check!
	elseif curStep == 155 then
		kbAttack(false) 	--Prepares the sawblade again
	elseif curStep == 156 then
		kbAttack(true, "old/attack_alt02")		--Dodge check!
	
	elseif curStep == 192 then
		kbPincerPrepare(2,false) 	--plays the enter animation for the pincer and adds it to the game scene
	elseif curStep == 196 then
		kbPincerGrab(2)				--Changes the pincer graphic to look like it's grabing the note
		if downscroll==0 then		--Moves the note down if playing with upscroll
			tweenPos('pincer2', x5, y5+20, 0.25, done)
			tweenPos(5, x5, y5+20, 0.25, done)
		else						--Moves the note up if playing with downscroll
			tweenPos('pincer2', x5, y5-20, 0.25, done)
			tweenPos(5, x5, y5-20, 0.25, done)
		--If moving notes up and down, don't move them too far because the timing window is still at the bottom / remains unaffected. This only creates misleading visuals which can frustrate players.
		end
	elseif curStep == 204 then
		kbPincerPrepare(2,true)		--Plays the leaving animation for the pincer and removes it from the scene once the animation is finished
		
	elseif curStep == 256 then
		tweenPos(5, x5, y5, 0.275, done) --Resets the moved note back to normal position
		
	elseif curStep == 288 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 292 then
		kbAttackAlert(false)
	elseif curStep == 296 then
		kbAttack(true)		--Dodge check!
		
	elseif curStep == 304 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 308 then
		kbAttackAlertDouble(false)
	elseif curStep == 312 then
		kbAttack(true, "old/attack_alt01")		--Dodge check!
	elseif curStep == 315 then
		kbAttack(false) 	--Prepares the sawblade again
	elseif curStep == 316 then
		kbAttack(true, "old/attack_alt02")		--Dodge check!
		
	elseif curStep == 320 then
		kbPincerPrepare(4,false)
	elseif curStep == 324 then
		kbPincerGrab(4)
	elseif curStep == 332 then
		tweenPos('pincer4', x7+52, y7, 0.3, done)
		tweenPos(7, x7+40, y7, 0.3, done)
	elseif curStep == 336 then
		kbPincerPrepare(4,true)

	elseif curStep == 376 then
		kbAttackAlert(false) --First alert
		kbAttack(false) 	--Prepares the sawblade
	elseif curStep == 380 then
		kbAttackAlert(false)
	elseif curStep == 384 then
		kbAttack(true)		--Dodge check!
		
	elseif curStep == 400 then
		tweenPos(7, x7, y7, 1, done)
	end
	
	
	
	
end

--Just commenting out the custom camera stuff so the sawblade is easier to see.
function playerTwoTurn()
    --tweenCameraZoom(1.3,(crochet * 4) / 1000)
end

function playerOneTurn()
    --tweenCameraZoom(1,(crochet * 4) / 1000)
end