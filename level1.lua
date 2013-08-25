-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local imgRectBackground, rectBunker, imgRectTank

local numCitizens = 5

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

	local function createCitizens()
		for i = 1, numCitizens do
			-- display citizen
			local imgRectCitizen = display.newImageRect( "images/game-citizen.png", 28, 31 )
			imgRectCitizen:setReferencePoint( display.TopLeftReferencePoint )

			local rndX = math.random(((rectBunker.x - rectBunker.width) - imgRectCitizen.width))
			imgRectCitizen.x = rndX
			imgRectCitizen.y = screenH - imgRectCitizen.height
		end
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
	rectBunker.x = screenW
	rectBunker.y = screenH
	group:insert( rectBunker )

	-- create bunker tank
	imgRectTank = display.newImageRect( "images/game-tank.png", 61, 56 )
	imgRectTank:setReferencePoint( display.TopLeftReferencePoint )
	imgRectTank.x = (rectBunker.x - rectBunker.width) + 20
	imgRectTank.y = rectBunker.y - (imgRectTank.height + rectBunker.height)
	group:insert( imgRectTank )

--print(rectBunker.x - rectBunker.width)

	createCitizens()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
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