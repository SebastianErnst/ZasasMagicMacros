Slots = {}

function Slots:getAllSlotTextures()
    for i = 1, 172 do
        if GetActionTexture(i) then
            print("Slot " .. i .. " " .. GetActionTexture(i))
        end
    end
end

function Slots:findSlotIndexByTextureName(textureName)
    for i = 1, 172 do
        if GetActionTexture(i) then
            local isSameTexture = strfind(GetActionTexture(i), textureName)
            if isSameTexture then
                return i
            end
        end
    end

    return -1
end

function Slots:printAll()

for i = 1, 172 do
  if GetActionTexture(i) then
    print(GetActionTexture(i))
  end
end

end

