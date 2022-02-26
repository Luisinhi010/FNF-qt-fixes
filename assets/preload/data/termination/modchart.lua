-- Variable definition:
local x4,x5,x6,x7,y4,y5,y6,y7,originalCamHudAngle

function start(song) -- do nothing
	-- Initialization
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
	local currentBeat = (songPos / 1000)*(bpm/60)
	
	if curBeat>=704 and curBeat<768 then
			for i=0,7 do
				setActorX(_G['defaultStrum'..i..'X'] + 10 * math.sin((currentBeat + i*0.25) * math.pi), i)
			end
	elseif curBeat>=768 and curBeat<832 then
			for i=0,7 do
				setActorX(_G['defaultStrum'..i..'X'] + 15 * math.sin((currentBeat + i*0.35) * math.pi), i)
			end
	elseif curBeat>=512 and curBeat<640 then
		camHudAngle = 4 * math.sin(currentBeat * math.pi)
		showOnlyStrums = true
		for i=1,6 do
			setActorX(_G['defaultStrum'..i..'X'] + 10 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
	elseif curBeat>=640 and curBeat<704 then
		camHudAngle = originalCamHudAngle
		showOnlyStrums = false
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'],i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
	elseif curBeat>=832 and curBeat<960 then
		camHudAngle = originalCamHudAngle
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'],i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
	elseif curBeat>=960 and curBeat<1024 then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 15 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
	elseif curBeat>=1024 and curBeat<1088 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 15 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 15 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 25 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
	elseif curBeat>=1088 and curBeat<1148 then
		camHudAngle = originalCamHudAngle
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'],i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
	else
		camHudAngle = originalCamHudAngle
	end
end

function beatHit(beat) -- For intro (notes fade in)	
	--Just after 1st drop.
	--1st pincer move
	if curBeat == 320 then
		kbPincerPrepare(3,false)
	elseif curBeat == 322 then
		kbPincerGrab(3)
		if downscroll==0 then
			tweenPos('pincer3', x6, y6+25, 0.25, done)
			tweenPos(6, x6, y6+25, 0.25, done)
		else
			tweenPos('pincer3', x6, y6-25, 0.25, done)
			tweenPos(6, x6, y6-25, 0.25, done)
		end
	elseif curBeat == 324 then
		kbPincerPrepare(3,true)
		
	--2nd pincer move
	elseif curBeat == 336 then
		kbPincerPrepare(1,false)
		kbPincerPrepare(3,false)
	elseif curBeat == 338 then
		kbPincerGrab(3)
		kbPincerGrab(1)
		tweenPos(6, x6, y6, 0.3, done)
		tweenPos('pincer3', x6, y6, 0.3, done)
		if downscroll==0 then
			tweenPos('pincer1', x4-30, y4+26, 0.25, done)
			tweenPos(4, x4-30, y4+26, 0.25, done)
		else
			tweenPos('pincer1', x4-30, y4-26, 0.25, done)
			tweenPos(4, x4-30, y4-26, 0.25, done)
		end
	elseif curBeat == 340 then
		kbPincerPrepare(1,true)
		kbPincerPrepare(3,true)
		
	--3rd pincer move
	elseif curBeat == 352 then
		kbPincerPrepare(1,false)
		kbPincerPrepare(4,false)
		kbPincerPrepare(2,false)
	elseif curBeat == 354 then
		kbPincerGrab(1)
		kbPincerGrab(4)
		kbPincerGrab(2)
		tweenPos(4, x4, y4, 0.3, done)
		tweenPos('pincer1', x4, y4, 0.3, done)
		if downscroll==0 then
			tweenPos(7, x7+55, y7+26, 0.25, done)
			tweenPos(5, x5+10, y5+29, 0.25, done)
			tweenPos('pincer4', x7+55, y7+26, 0.25, done)
			tweenPos('pincer2', x5+10, y5+29, 0.25, done)
		else
			tweenPos(7, x7+55, y7-26, 0.25, done)
			tweenPos(5, x5+10, y5-29, 0.25, done)
			tweenPos('pincer4', x7+55, y7-26, 0.25, done)
			tweenPos('pincer2', x5+10, y5-29, 0.25, done)
		end
	elseif curBeat == 356 then
		kbPincerPrepare(1,true)
		kbPincerPrepare(4,true)
		kbPincerPrepare(2,true)
		
	--4th pincer move
	elseif curBeat == 368 then
		kbPincerPrepare(1,false)
		kbPincerPrepare(2,false)
		kbPincerPrepare(3,false)
		kbPincerPrepare(4,false)
	elseif curBeat == 370 then
		kbPincerGrab(1)
		kbPincerGrab(4)
		kbPincerGrab(2)
		kbPincerGrab(3)
		if downscroll==0 then
			tweenPos(6, x6, y6-12, 0.25, done)
			tweenPos(5, x5, y5-12, 0.25, done)
			tweenPos(7, x7+22, y7+20, 0.25, done)
			tweenPos(4, x4-22, y4+20, 0.25, done)
			tweenAngle(7, 40, 0.25, done)
			tweenAngle(4, -40, 0.25, done)
			tweenPos('pincer3', x6, y6-12, 0.25, done)
			tweenPos('pincer2', x5, y5-12, 0.25, done)
			tweenPos('pincer4', x7+22, y7+20, 0.25, done)
			tweenPos('pincer1', x4-22, y4+20, 0.25, done)
		else
			tweenPos(6, x6, y6+12, 0.25, done)
			tweenPos(5, x5, y5+12, 0.25, done)
			tweenPos(7, x7+22, y7-20, 0.25, done)
			tweenPos(4, x4-22, y4-20, 0.25, done)
			tweenAngle(7, -40, 0.25, done)
			tweenAngle(4, 40, 0.25, done)
			tweenPos('pincer3', x6, y6+12, 0.25, done)
			tweenPos('pincer2', x5, y5+12, 0.25, done)
			tweenPos('pincer4', x7+22, y7-20, 0.25, done)
			tweenPos('pincer1', x4-22, y4-20, 0.25, done)
		end
	elseif curBeat == 372 then
		kbPincerPrepare(1,true)
		kbPincerPrepare(2,true)
		kbPincerPrepare(3,true)
		kbPincerPrepare(4,true)
		
	elseif curBeat == 383 then
		kbPincerPrepare(1,false)
		kbPincerPrepare(4,false)

	--The long note section before 2nd drop.
	--4 and 7 swap
	elseif curBeat == 384 then --Y offset
		kbPincerGrab(4)
		kbPincerGrab(1)
		tweenPos(4, x4, y4+75, 0.75, done)
		tweenPos(7, x7, y7-75, 0.75, done)
		tweenPos('pincer1', x4, y4+75, 0.75, done)
		tweenPos('pincer4', x7, y7-75, 0.75, done)
		tweenAngle(7, 0, 0.6, done)
		tweenAngle(4, 0, 0.6, done)
	elseif curBeat == 388 then --Swap
		tweenPos(4, x7, getActorY(4), 0.75, done)
		tweenPos(7, x4, getActorY(7), 0.75, done)
		tweenPos('pincer1', x7, getActorY(4), 0.75, done)
		tweenPos('pincer4', x4, getActorY(7), 0.75, done)
	elseif curBeat == 392 then --Reset Y offset
		tweenPos(4, getActorX(4), y4, 0.75, done)
		tweenPos(7, getActorX(7), y7, 0.75, done)
		tweenPos('pincer1', getActorX(4), y4, 0.75, done)
		tweenPos('pincer4', getActorX(7), y7, 0.75, done)
		
	--5 and 6 swap
	elseif curBeat == 400 then --Y offset
		kbPincerGrab(3)
		kbPincerGrab(2)
		tweenPos(6, x6, y6+75, 0.75, done)
		tweenPos(5, x5, y5-75, 0.75, done)
		tweenPos('pincer3', x6, y6+75, 0.75, done)
		tweenPos('pincer2', x5, y5-75, 0.75, done)
	elseif curBeat == 404 then --Swap
		tweenPos(6, x5, getActorY(6), 0.75, done)
		tweenPos(5, x6, getActorY(5), 0.75, done)
		tweenPos('pincer3', x5, getActorY(6), 0.75, done)
		tweenPos('pincer2', x6, getActorY(5), 0.75, done)
	elseif curBeat == 408 then --Reset Y offset
		tweenPos(6, getActorX(6), y6, 0.75, done)
		tweenPos(5, getActorX(5), y5, 0.75, done)
		tweenPos('pincer3', getActorX(6), y6, 0.75, done)
		tweenPos('pincer2', getActorX(5), y5, 0.75, done)
		
	--Reset swaps
	elseif curBeat == 448 then 
		tweenPos(7, x7, y7, 0.6, done)
		tweenPos(6, x6, y6, 0.6, done)
		tweenPos(5, x5, y5, 0.6, done)
		tweenPos(4, x4, y4, 0.6, done)
	
	elseif curBeat == 510 then
		kbPincerPrepare(4,false)
		kbPincerPrepare(5,false)
	elseif curBeat == 512 then
		kbPincerGrab(4)
		kbPincerGrab(5)
	elseif curBeat == 640 then
		kbPincerPrepare(4,true)
		kbPincerPrepare(5,true)
	end	
end

function stepHit(step) -- do nothing
	if curStep == 1584 then --For some dumb reason, doesn't want to work using beathit, but works on stephit. dafuq?
		kbPincerPrepare(1,true)
		kbPincerPrepare(4,true)
		kbPincerPrepare(2,false)
		kbPincerPrepare(3,false)
	elseif curStep == 1648 then
		kbPincerPrepare(3,true)
		kbPincerPrepare(2,true)
	end
end