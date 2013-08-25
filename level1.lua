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

local imgRectBackground, rectBunker, imgRectTank

local numSIdRows = 3
local numSIdCols = 10
local sidSpeed = 5

local bunkerDoor = 0

local numCitizens = 10
local citizenSpeed = 2

local imgRectGroupCitizen = display.newGroup()
local imgRectGroupSId = display.newGroup()

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

	function moveEnemies()
		-- Move Enemies
		imgRectGroupSId.x = imgRectGroupSId.x + sidSpeed

		if((imgRectGroupSId.x + (imgRectGroupSId.width * 0.5)) > (display.contentWidth - 10)) then
			sidSpeed = -3
		end

		if((imgRectGroupSId.x - (imgRectGroupSId.width * 0.5)) < 10) then
			sidSpeed = 3
		end
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
		print("collision detected")
		print(e.other.name)
		print(e.target.name)
		print("----------------")
	end

	local function createCitizens()
		for i = 1, numCitizens do
			-- display citizen
			local imgRectCitizen = display.newImageRect( "images/game-citizen.png", 28, 31 )
			imgRectCitizen:setReferencePoint( display.TopLeftReferencePoint )

			bunkerDoor = ((rectBunker.x - rectBunker.width) - imgRectCitizen.width)
print(bunkerDoor)

			--local rndX = math.random(((rectBunker.x - rectBunker.width) - imgRectCitizen.width))
			local rndX = math.random(bunkerDoor)
			imgRectCitizen.x = rndX
			imgRectCitizen.y = screenH - imgRectCitizen.height
			imgRectCitizen.dir = "R"

			imgRectGroupCitizen:insert( imgRectCitizen )
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
				imgRectSId.x = topLeft.x + (col * sidWidth) + hPadding
				imgRectSId.y = topLeft.y + (row * sidHeight) + vPadding
				imgRectSId:setReferencePoint( display.CenterReferencePoint )
				imgRectSId:toFront()
				imgRectSId.name = "sid"

				imgRectGroupSId:insert( imgRectSId )

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
	end



	-- display background
	imgRectBackground = display.newImageRect( "images/game-background.png", display.contentWidth, display.contentHeight )
	imgRectBackground:setReferencePoint( display.TopLeftReferencePoint )
	imgRectBackground.x = 0
	imgRectBackground.y = 0
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

	createCitizens()

	createSIds()

	Runtime:addEventListener('enterFrame', update)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

--[[
	physics.start()

	physics.setGravity(0, 0)

	physics.setDrawMode( "hybrid" )
--]]

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