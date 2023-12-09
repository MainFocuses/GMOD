--- Define the menu options
local menuOptions = {
    "Toggle Cheat FOV",
    "Toggle Crosshair",
    "Toggle Draw Render Boxes",
    "Give Ammo",
    "Kill Yourself"
}

-- Variables to store the player's custom FOV and default FOV
local customFOV = 120
local defaultFOV = 120
local targetFOV = customFOV
local isFOVHackEnabled = false
local isCrosshairEnabled = false

-- Variable to store the state of r_drawrenderboxes
local isRenderBoxesEnabled = false

-- Variable to control the FOV interpolation speed
local fovInterpolationSpeed = 5 -- Adjust the speed as needed

-- Function to interpolate FOV
local function InterpolateFOV()
    customFOV = Lerp(FrameTime() * fovInterpolationSpeed, customFOV, targetFOV)

    hook.Add("CalcView", "CustomFOV", function(ply, pos, angles, fov)
        return {
            origin = pos,
            angles = angles,
            fov = customFOV
        }
    end)
end

-- Function to create the menu
local function CreateMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 500)
    frame:SetPos(10, 10)
    frame:SetTitle("gm_cm")
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 255))
    end

    local yOffset = 30

    for index, option in ipairs(menuOptions) do
        local button = vgui.Create("DButton", frame)
        button:SetText(option)
        button:SetSize(200, 30)
        button:SetPos(50, yOffset)

        if index == 5 then
            button.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(255, 0, 0, 255))
            end

            button:SetFont("DermaLarge")
            button:SetText("Kill Yourself")
        end

        button.DoClick = function()
            if index == 1 then
                isFOVHackEnabled = not isFOVHackEnabled

                if isFOVHackEnabled then
                    targetFOV = 150
                else
                    targetFOV = defaultFOV
                end
            elseif index == 2 then
                isCrosshairEnabled = not isCrosshairEnabled

                if isCrosshairEnabled then
                    hook.Add("HUDPaint", "DrawCrosshair", function()
                        surface.SetDrawColor(255, 0, 0, 255)  -- Set color to red (R: 255, G: 0, B: 0)
                        surface.DrawLine(ScrW() / 2 - 10, ScrH() / 2, ScrW() / 2 + 10, ScrH() / 2)
                        surface.DrawLine(ScrW() / 2, ScrH() / 2 - 10, ScrW() / 2, ScrH() / 2 + 10)
                    end)
                else
                    hook.Remove("HUDPaint", "DrawCrosshair")
                end
            elseif index == 3 then
                isRenderBoxesEnabled = not isRenderBoxesEnabled
                local command = isRenderBoxesEnabled and "r_drawrenderboxes 1" or "r_drawrenderboxes 0"
                LocalPlayer():ConCommand(command)
            elseif index == 4 then
                print("Clicked on Give Ammo")
                LocalPlayer():ConCommand("givecurrentammo")
            elseif index == 5 then
                LocalPlayer():ConCommand("kill")
            else
                print("Clicked on " .. option)
            end
        end

        if index == #menuOptions then
            local infoLabel = vgui.Create("DLabel", frame)
            infoLabel:SetText("Toggle Draw Render Boxes requires server variable sv_cheats 1 to be enabled.")
            infoLabel:SetSize(280, 40)
            infoLabel:SetPos(10, yOffset + 50)
            infoLabel:SetTextColor(Color(0, 255, 0))
        end

        yOffset = yOffset + 40
    end

    hook.Add("Think", "InterpolateFOV", InterpolateFOV)
end

-- Hook to open the menu on gm_showspare2
hook.Add("PlayerBindPress", "OpenGModMenu", function(ply, bind, pressed)
    if bind == "gm_showspare2" and pressed then
        CreateMenu()
    end
end)