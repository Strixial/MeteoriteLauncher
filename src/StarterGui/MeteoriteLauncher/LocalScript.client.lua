local RunService = game:GetService("RunService")
while true do
	local dt = RunService.RenderStepped:Wait()
	script.Parent.Rotation += dt * 60 * 2
end