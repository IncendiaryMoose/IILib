-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')
require('II_SmallVectorMath')

BARREL_LENGTH = property.getNumber('Barrel Length')
WEAPON_TYPE = property.getNumber('Weapon Type')
WEAPON_DATA = {
	{800, 0.025, 300}, --MG
	{1000, 0.02, 300}, --LA
	{1000, 0.01, 300}, --RA
	{900, 0.005, 600}, --HA
	{800, 0.002, 3600}, --BA
	{700, 0.001, 3600}, --AR
	{600, 0.0005, 3600}, --BE
}
WEAPON = WEAPON_DATA[WEAPON_TYPE]
MUZZLE_VELOCITY = WEAPON[1]/60
DRAG = WEAPON[2]
LIFESPAN = WEAPON[3]

g = -30/3600 -- bullet gravity in meters/tick/tick

GRAVITY = IIVector(0, 0, g)
terminalVelocity = IIVector(0, 0, GRAVITY / DRAG)

function newBullet(initialPosition, initialVelocity)
    return {
        position = IIVector(),
        initialPosition = initialPosition:cloneVector(),
        positionDelta = IIVector(),
        velocity = IIVector(),
        initialVelocity = initialVelocity:cloneVector(),
        speed = MUZZLE_VELOCITY,
        distance = 0,
        positionInTicks = function (self, t)
            local A = e^(-DRAG * t) -- A term used in both the velocity and position functions, so if both are being computed it can be reused

            self.velocity:copyVector(self.initialVelocity) -- Reset velocity to starting point
            self.velocity:setScale(A) -- Scales velocity by A
            self.velocity:setAdd(terminalVelocity, 1 - A) -- adds terminal velocity scaled by 1 - A to velocity. V = V + tV * (1-A)

            self.position:copyVector(self.initialVelocity) -- Sets position to starting velocity
            self.position:setAdd(terminalVelocity, -1) -- Subtracts terminal velocity from position
            self.position:setScale((1 - A)/DRAG) -- Scales position
            self.position:setAdd(terminalVelocity, t) -- Adds terminal velocity * t to position. t is the time in ticks

            self.distance = self.position:magnitude()

            self.position:setAdd(self.initialPosition) -- Adds the starting position of the bullet to the computed position

            self.speed = self.velocity:magnitude()
        end
    }
end