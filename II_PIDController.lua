-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')

---@section newPID
---Creates a new PID controller from the supplied config
---@param PID_CONFIG table The configuration for the new PID controller
---Must contain the following:
--- PROPORTIONAL_GAIN - Output contains the measured error multipled by this value
--- INTEGRAL_GAIN - Output contains the total measured error over time multipled by this value
--- DERIVATIVE_GAIN - Output contains the delta of measured error multipled by this value
---Can optionally contain:
--- MAX_PROPORTIONAL - Proportional component of output will be restricted to +- this value
--- MAX_INTEGRAL - Integral component of output will be restricted to +- this value
--- MAX_DERIVATIVE - Derivative component of output will be restricted to +- this value
--- MAX_OUTPUT - Output will be restricted to +- this value
--- OFFSET - Output will be offset by this value, within MAX_OUTPUT if one is specified
---@return table PID PID controller created using provided settings
function newPID(PID_CONFIG)
    return {
        PROPORTIONAL_GAIN = PID_CONFIG.PROPORTIONAL_GAIN,
        INTEGRAL_GAIN = PID_CONFIG.INTEGRAL_GAIN,
        DERIVATIVE_GAIN = PID_CONFIG.DERIVATIVE_GAIN,

        MAX_PROPORTIONAL = hugeIfZero(PID_CONFIG.MAX_PROPORTIONAL),
        MAX_INTEGRAL = hugeIfZero(PID_CONFIG.MAX_INTEGRAL),
        MAX_DERIVATIVE = hugeIfZero(PID_CONFIG.MAX_DERIVATIVE),
        MAX_OUTPUT = hugeIfZero(PID_CONFIG.MAX_OUTPUT),
        OFFSET = PID_CONFIG.OFFSET or 0,

        update = function (self, setpoint, processVariable)
            local measuredError = setpoint - processVariable

            self.proportional = clampAbs(
                measuredError * self.PROPORTIONAL_GAIN,
                self.MAX_PROPORTIONAL
            )

            self.integral = self.integral and clampAbs(
                self.integral + measuredError * self.INTEGRAL_GAIN,
                self.MAX_INTEGRAL
            ) or 0

            self.derivative = self.previousError and clampAbs(
                (measuredError - self.previousError) * self.DERIVATIVE_GAIN,
                self.MAX_DERIVATIVE
            ) or 0
            self.previousError = measuredError

            self.output = clampAbs(
                self.proportional + self.integral + self.derivative + self.OFFSET,
                self.MAX_OUTPUT
            )

            return self.output
        end
    }
end
---@endsection