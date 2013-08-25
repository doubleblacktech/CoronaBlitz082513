-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local physics = require('physics')

physics.start()

physics.setGravity(0, 0)

--physics.setDrawMode( "hybrid" )

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local imgRectBackground, rectBunker, imgRectTank, rectFloor

local laser, missile, blast, firePointX, firePointX

local numSIdRows = 3
local numSIdCols = 10
local sidSpeed = 5
local newRectGroupLaser = display.newGroup()
local laserSpeed = 5

local bunkerDoor = 0

local numCitizens = 10
local citizenSpeed = 3
local citizenDir = {"L", "R"}

local imgRectGroupCitizen = display.newGroup()
local imgRectGroupSId = display.newGroup()

local collisionDetected = false
local laserTimerSource

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	math.randomseed( os.time() )

	local function touchHandler( event )
		if ( event.phase == "ended" ) then
			missile = display.newRect(firePointX, firePointY, 5, 5)
			missile.x = firePointX
			missile.y = firePointY
			missile.name = "missile"
			missile:setFillColor( 255 )

			physics.addBody(missile, "static", {friction=0, bounce = 1})
			missile:addEventListener('collision', collisionHandler)

			transition.to(missile, {time=400, x=event.x, y=event.y, onComplete=
				function()
--print("missile completed")
--print(collisionDetected)
					if collisionDetected == false and missile ~= nil then
						blast = display.newCircle( event.x, event.y, 20 )
						blast:setFillColor(255,255,255)
						blast.name = "blast"
						physics.addBody(blast)
						blast.bodyType = 'static'
						blast:addEventListener('collision', collisionHandler)

						if missile ~= nil then
							missile:removeSelf()
							missile = nil
						end

						transition.to(blast, {time=800, xScale=1.5, yScale=1.5, alpha=0.0, onComplete=
							function()
								blast:removeSelf()
								blast = nil
							end
						})
					else
						collisionDetected = false
					end
				end
			})
		end
	end

	function moveEnemies()
		imgRectGroupSId.x = imgRectGroupSId.x + sidSpeed
		--imgRectGroupSId:translate(sidSpeed, 0)

		if((imgRectGroupSId.x + (imgRectGroupSId.width * 0.5)) > (display.contentWidth - 10)) then
			sidSpeed = -3
		end

		if((imgRectGroupSId.x - (imgRectGroupSId.width * 0.5)) < 10) then
			sidSpeed = 3
		end
	end

	function moveLasers()
		local numLasers = newRectGroupLaser.numChildren
		if(numLasers > 0) then
			for i = 1, numLasers do
				newRectGroupLaser[i].y = newRectGroupLaser[i].y + laserSpeed
			end

--newRectGroupLaser[1].y = newRectGroupLaser[1].y + laserSpeed
--print(newRectGroupLaser[1].y)

		end
	end

	function sidFire(e)

		local rndSId = math.random(1, imgRectGroupSId.numChildren)
		local currentSId = imgRectGroupSId[rndSId]

		local realSIdX, realSIdY = currentSId:localToContent( 0, 0 )

		newRectLaser = display.newRect(realSIdX, realSIdY, 10, 20)
		newRectLaser.x = realSIdX
		newRectLaser.y = realSIdY
		newRectLaser.name = "laser"
		newRectLaser:setFillColor( 255 )

		physics.addBody(newRectLaser, "dynamic", {friction=0, bounce = 1, isBullet = true})
		newRectLaser:addEventListener('collision', collisionHandler)

		newRectGroupLaser:insert( newRectLaser )
	end

	function moveCitizens()
		if(imgRectGroupCitizen.numChildren ~= 0) then
			for i = 1, imgRectGroupCitizen.numChildren do
				if(imgRectGroupCitizen[i] ~= nil) then

					-- Test Direction Right
					if(imgRectGroupCitizen[i].dir == "R") then

						-- Test Right bounds
						if(imgRectGroupCitizen[i].x < (bunkerDoor - 20)) then
							imgRectGroupCitizen[i].x = imgRectGroupCitizen[i].x + citizenSpeed
						else
							imgRectGroupCitizen[i].dir = "L"
						end

					-- Test Direction Left
					elseif(imgRectGroupCitizen[i].dir == "L") then

						-- Test Left bounds
						if (imgRectGroupCitizen[i].x > 10) then
							imgRectGroupCitizen[i].x = imgRectGroupCitizen[i].x - citizenSpeed
						else
							imgRectGroupCitizen[i].dir = "R"
						end

					end 	-- END: Test Direction Left

				end
			end
		end
	end

	function collisionHandler(e)
--[[
print("collision detected")
print(e.other.name)
print(e.target.name)
print("----------------")
--]]
		if(e.other.name == 'laser' and e.target.name == 'citizen') then
			e.other:removeSelf()
			e.other = nil

			e.target:removeSelf()
			e.target = nil
		elseif(e.other.name == 'laser' and e.target.name == 'floor') then
			e.other:removeSelf()
			e.other = nil
		elseif(e.other.name == 'laser' and e.target.name == 'blast') then
--[[
print("collision detected")
print(e.other.name)
print(e.target.name)
print("----------------")
--]]
			e.other:removeSelf()
			e.other = nil
		end
	end

	local function createCitizens()
		for i = 1, numCitizens do
			-- display citizen
			local imgRectCitizen = display.newImageRect( "images/game-citizen.png", 28, 31 )
			imgRectCitizen:setReferencePoint( display.TopLeftReferencePoint )

			bunkerDoor = ((rectBunker.x - rectBunker.width) - imgRectCitizen.width)

			local rndX = math.random(bunkerDoor)

			imgRectCitizen.x = rndX
			imgRectCitizen.y = screenH - imgRectCitizen.height

			local rndDir = math.random(1, 2)
			local selDirection = citizenDir[rndDir]

			imgRectCitizen.dir = selDirection

			imgRectCitizen.name = "citizen"

			imgRectGroupCitizen:insert( imgRectCitizen )

			physics.addBody(imgRectCitizen, "static", {friction=0, bounce = 1})
			imgRectCitizen:addEventListener('collision', collisionHandler)
		end

		group:insert( imgRectGroupCitizen )
	end

	local function createSIds()
		local sidWidth = 64
		local sidHeight = 64
		local gutter = 20
		local enemyCnt = 0

		local numOfRows = 3
		local numOfCols = 10

		local topLeft = {x=0, y=0}

		local row
		local col
		local hPadding = 0
		local vPadding = 0

		for row = 0, numOfRows - 1 do
			if row > 0 then
				vPadding = vPadding + gutter
			end

			for col = 0, numOfCols - 1 do
				if col > 0 then
					hPadding = hPadding + gutter
				end
				
				-- Create an enemy
				enemyCnt = enemyCnt + 1

				local imgRectSId = display.newImageRect( "images/alien-a-1.png", 64, 64 )
				imgRectSId:setReferencePoint( display.CenterReferencePoint )

				imgRectGroupSId:insert( imgRectSId )

				imgRectSId.x = topLeft.x + (col * sidWidth) + hPadding
				imgRectSId.y = topLeft.y + (row * sidHeight) + vPadding
				imgRectSId:toFront()
				imgRectSId.name = "sid"

				physics.addBody(imgRectSId, "static", {friction=0, bounce = 1})
				imgRectSId:addEventListener('collision', collisionHandler)
			end

			hPadding = 0
		end

		hPadding = 0
		vPadding = 0

		imgRectGroupSId:setReferencePoint( display.TopCenterReferencePoint )
		imgRectGroupSId.x = (display.contentWidth * 0.5)
		imgRectGroupSId.y = 10
		imgRectGroupSId:toFront()
	end

	function update(e)
		moveEnemies()

		moveCitizens()

		moveLasers()
	end

	-- display floor
	rectFloor = display.newRect( 0, display.contentHeight, display.contentWidth, 10 )
	rectFloor:setReferencePoint( display.TopLeftReferencePoint )
	rectFloor.x = 0
	rectFloor.y = display.contentHeight - 10
	rectFloor:setFillColor( black )
	rectFloor.name = "floor"
	physics.addBody(rectFloor, "static", {friction=0, bounce = 1})
	rectFloor:addEventListener('collision', collisionHandler)
	group:insert( rectFloor)

	-- display background
	imgRectBackground = display.newImageRect( "images/game-background.png", display.contentWidth, display.contentHeight )
	imgRectBackground:setReferencePoint( display.TopLeftReferencePoint )
	imgRectBackground.x = 0
	imgRectBackground.y = 0
	imgRectBackground:addEventListener( "touch", touchHandler )
	group:insert( imgRectBackground )
	
	-- create bunker recangle
	rectBunker = display.newRect( 0, 0, 100, 50 )
	rectBunker:setReferencePoint( display.BottomRightReferencePoint )
	rectBunker:setFillColor( black )
	rectBunker.x = screenW
	rectBunker.y = screenH
	group:insert( rectBunker )

	-- create bunker tank
	imgRectTank = display.newImageRect( "images/game-tank.png", 61, 56 )
	imgRectTank:setReferencePoint( display.TopLeftReferencePoint )
	imgRectTank.x = (rectBunker.x - rectBunker.width) + 20
	imgRectTank.y = rectBunker.y - (imgRectTank.height + rectBunker.height)
	group:insert( imgRectTank )

	firePointX = imgRectTank.x + (imgRectTank.width * 0.2)
	firePointY = imgRectTank.y

	createCitizens()

	createSIds()

	Runtime:addEventListener('enterFrame', update)

	laserTimerSource = timer.performWithDelay(2000, sidFire, 0)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene