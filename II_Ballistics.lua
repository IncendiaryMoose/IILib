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

---@section newtonMethodBallistics
--- There are 3 possible solutions to the equation.
--- There is the correct solution, the 'mortar' solution, and the firing the bullet in reverse solution.
--- The reverse solution can be filtered out by checking if the result is negative
--- The mortar solution is mostly a non-issue, as it will not be reached in normal situations.
--- Even if the solver arrives at the mortar solution, the bullet will still hit.
---@param initialVelocity IIVector The velocity of the turret in world-space. The bullet will inherit this velocity when fired, so it needs to be accounted for.
---@param target table The target to hit. Must include a positionInTicks() function and a predictedPosition IIVector
---@param predictedTime number The predicted time, in ticks, that will pass between firing the bullet and hitting the target.
---@return number turretElevation The elevation, in world-space radians, of the turret that will be needed to hit the target. 0 is horizontal.
---@return number turretAzimuth The azimuth (yaw), in world-space radians, of the turret that will be needed to hit the target. 0 is east.
---@return number flightTime The predicted flight time of the bullet.
function newtonMethodBallistics(initialVelocity, target, predictedTime)
    local Z2, azimuthDifference, previousAzimuthDifference, azimuthDifferencePrime, E, E1, Z, IV
    Z2 = TERMINAL_VELOCITY[3] - initialVelocity[3]
    for j = 1, 8 do
        -- Find where the target is probably going to be when the bullet lands
        target:positionInTicks(predictedTime)

        -- Reset azimuthDifference to avoid false positive on the early return
        azimuthDifference = 7

        -- Find what time the bullet will actually hit that location
        for i = 1, 5 do
            E = e^(-DRAG * predictedTime)
            E1 = 1 - E
            Z = target.predictedPosition[3] - predictedTime * TERMINAL_VELOCITY[3]
            IV = E1 * (MUZZLE_VELOCITY^2 - Z2^2 - initialVelocity[1]^2 - initialVelocity[2]^2) + 2 * DRAG * (target.predictedPosition[2] * initialVelocity[2] + target.predictedPosition[1] * initialVelocity[1] - Z * Z2)

            previousAzimuthDifference = azimuthDifference
            -- This equation returns the difference between the azimuth angle calculated using the given time in the X-Z plane and the Y-Z plane.
            azimuthDifference = E1 * IV - DRAG^2 * (target.predictedPosition[1]^2 + target.predictedPosition[2]^2 + Z^2)

            -- This is the derivative of the previous equation. This is required for newton's method.
            azimuthDifferencePrime = 2 * (DRAG * (E * IV + TERMINAL_VELOCITY[3] * (E1 * Z2 - DRAG * Z)))

            -- Newton's method. The next guess is equal to the first guess, offset in the direction the graph is going. This results in the next guess resulting in a number closer to 0 than the current one.
            predictedTime = predictedTime - azimuthDifference / azimuthDifferencePrime

            if predictedTime > LIFESPAN or predictedTime < 0 or IIabs(azimuthDifference) > IIabs(previousAzimuthDifference) then
                -- The prediction system is not going to find a solution, so don't waste time trying.
                return 0, 0, 0
            end
        end
    end
    E1 = 1 - e^(-DRAG * predictedTime)
    return
        -- Compute elevation and azimuth angles based on the predictedTime
        arcsin((DRAG * (target.predictedPosition[3] - predictedTime * TERMINAL_VELOCITY[3])) / (MUZZLE_VELOCITY * E1) + Z2 / MUZZLE_VELOCITY),
        math.atan(DRAG * target.predictedPosition[2] / E1 - initialVelocity[2], DRAG * target.predictedPosition[1] / E1 - initialVelocity[1]),
        predictedTime
end
---@endsection