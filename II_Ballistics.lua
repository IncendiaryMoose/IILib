-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')
require('II_SmallVectorMath')

MAX_ATTEMPTS = 5
MAX_STEPS = 5
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

G = -30/3600 -- bullet gravity in meters/tick/tick

GRAVITY = IIVector(0, 0, G)
TERMINAL_VELOCITY = IIVector(0, 0, G/DRAG)
MAX_RANGE = (1/DRAG) * MUZZLE_VELOCITY

---@section newBullet
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
            self.velocity:setAdd(TERMINAL_VELOCITY, 1 - A) -- adds terminal velocity scaled by 1 - A to velocity. V = V + tV * (1-A)

            self.position:copyVector(self.initialVelocity) -- Sets position to starting velocity
            self.position:setAdd(TERMINAL_VELOCITY, -1) -- Subtracts terminal velocity from position
            self.position:setScale((1 - A)/DRAG) -- Scales position
            self.position:setAdd(TERMINAL_VELOCITY, t) -- Adds terminal velocity * t to position. t is the time in ticks

            self.distance = self.position:magnitude()

            self.position:setAdd(self.initialPosition) -- Adds the starting position of the bullet to the computed position

            self.speed = self.velocity:magnitude()
        end
    }
end
---@endsection

function newtonMethod(initialVelocity, targetPosition, currentIteration)
    local targetX, targetY, targetZ, Z2 = targetPosition[1], targetPosition[2], targetPosition[3], TERMINAL_VELOCITY[3] - initialVelocity[3]
    for i = 1, 5 do
        -- TODO: Early break if second attempt is further than first, and either try a different start or quit
        local E, EPrime, Z, IV2 = 1 - e^(-DRAG * currentIteration), DRAG * e^(-DRAG * currentIteration), targetZ - currentIteration * TERMINAL_VELOCITY[3], MUZZLE_VELOCITY^2 - Z2^2 - initialVelocity[1]^2 - initialVelocity[2]^2
        local IV = 2 * DRAG * (targetY * initialVelocity[2] + targetX * initialVelocity[1] - Z * Z2)

        local F = E^2 * IV2 + E * IV - DRAG^2 * (targetX^2 + targetY^2 + Z^2)

        local FPrime = 2 * E * EPrime * IV2 + EPrime * IV + E * (2 * DRAG * TERMINAL_VELOCITY[3] * (TERMINAL_VELOCITY[3] - initialVelocity[3])) - 2 * DRAG^2 * TERMINAL_VELOCITY[3] * Z

        currentIteration = currentIteration - F / FPrime
    end
    local E = 1 - e^(-DRAG * currentIteration)
    local turretPitch = arcsin((DRAG * (targetZ - currentIteration * TERMINAL_VELOCITY[3])) / (MUZZLE_VELOCITY * E) + (TERMINAL_VELOCITY[3] - initialVelocity[3]) / MUZZLE_VELOCITY)
    local turretYaw = math.atan(DRAG * targetY / E - initialVelocity[2], DRAG * targetX / E - initialVelocity[1])
    return turretPitch, turretYaw, currentIteration
end