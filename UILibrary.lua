local UILibrary = {}
UILibrary.__index = UILibrary

-- Типы для строгой типизации
type Component = {
    frame: Frame,
    value: any,
    enabled: boolean
}

-- Базовый конструктор компонента
function UILibrary.new(parent: Instance): Component
    local self = setmetatable({}, UILibrary)
    self.frame = Instance.new("Frame", parent)
    self.frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.frame.BorderSizePixel = 0
    self.value = nil
    self.enabled = false
    return self
end

-- Создание Toggle компонента
function UILibrary.createToggle(parent: Instance, text: string): Component
    local toggle = UILibrary.new(parent)
    toggle.frame.Size = UDim2.new(0, 100, 0, 30)
    toggle.frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local textLabel = Instance.new("TextButton", toggle.frame)
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    
    local indicator = Instance.new("Frame", toggle.frame)
    indicator.Size = UDim2.new(0, 20, 1, 0)
    indicator.Position = UDim2.new(1, -25, 0, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    textLabel.MouseButton1Click:Connect(function()
        toggle.enabled = not toggle.enabled
        indicator.BackgroundColor3 = toggle.enabled 
            and Color3.fromRGB(0, 255, 0) 
            or Color3.fromRGB(100, 100, 100)
    end)
    
    return toggle
end

-- Создание Slider компонента
function UILibrary.createSlider(parent: Instance, text: string, minValue: number, maxValue: number): Component
    local slider = UILibrary.new(parent)
    slider.frame.Size = UDim2.new(0, 200, 0, 30)
    slider.frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local textLabel = Instance.new("TextButton", slider.frame)
    textLabelText = text
    textLabelSize = UDim2.new(0.5, 0, 1, 0)
    textLabelBackgroundTransparency = 1
    
    local sliderBar = Instance.new("Frame", slider.frame)
    sliderBar.Size = UDim2.new(0.5, 0, 0.3, 0)
    sliderBar.Position = UDim2.new(0.5, 0, 0.5, 0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    local handle = Instance.new("Frame", sliderBar)
    handle.Size = UDim2.new(0, 20, 1, 0)
    handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Логика перемещения слайдера
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return slider
end

-- Создание кнопки с кастомизацией
function UILibrary.createButton(parent: Instance, text: string, callback: () -> ()): Component
    local button = UILibrary.new(parent)
    button.frame.Size = UDim2.new(0, 120, 0, 30)
    
    local textButton = Instance.new("TextButton", button.frame)
    textButton.Size = UDim2.new(1, 0, 1, 0)
    textButton.Text = text
    textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    textButton.MouseButton1Click:Connect(callback or function() end)
    
    -- Эффект наведения и нажатия
    textButton.MouseEnter:Connect(function()
        textButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    
    textButton.MouseLeave:Connect(function()
        textButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    return button
end

-- Создание выпадающего списка
function UILibrary.createDropdown(parent: Instance, text: string, options: {string}): Component
    local dropdown = UILibrary.new(parent)
    dropdown.frame.Size = UDim2.new(0, 150, 0, 30)
    
    local mainButton = Instance.new("TextButton", dropdown.frame)
    mainButton.Size = UDim2.new(1, 0, 1, 0)
    mainButton.Text = text
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local dropdownList = Instance.new("Frame", dropdown.frame)
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 1, 0)
    dropdownList.Visible = false
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    -- Создание списка опций
    for i, optionText in ipairs(options) do
        local option = Instance.new("TextButton", dropdownList)
        option.Size = UDim2.new(1, 0, 0, 30)
        option.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        option.Text = optionText
        option.TextColor3 = Color3.fromRGB(200, 200, 200)
        option.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        option.MouseButton1Click:Connect(function()
            mainButton.Text = optionText
            dropdownList.Visible = false
            dropdown.value = optionText
        end)
    end
    
    mainButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        dropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
    end)
    
    return dropdown
end

-- Создание привязки клавиш
function UILibrary.createKeybind(parent: Instance, text: string, defaultKey: string): Component
    local keybind = UILibrary.new(parent)
    keybind.frame.Size = UDim2.new(0, 150, 0, 30)
    
    local bindButton = Instance.new("TextButton", keybind.frame)
    bindButton.Size = UDim2.new(1, 0, 1, 0)
    bindButton.Text = text .. ": " .. defaultKey
    bindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local currentKey = defaultKey
    local listening = false
    
    bindButton.MouseButton1Click:Connect(function()
        if not listening then
            bindButton.Text = text .. ": [Listening...]"
            listening = true
            
            local connection
            connection = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if listening then
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = input.KeyCode.Name
                        bindButton.Text = text .. ": " .. currentKey
                        keybind.value = currentKey
                        listening = false
                        connection:Disconnect()
                    end
                end
            end)
        end
    end)
    
    return keybind
end

-- Создание выбиратеся цвета
function UILibrary.createColorPicker(parent: Instance, text: string): Component
    local colorPicker = UILibrary.new(parent)
    colorPicker.frame.Size = UDim2.new(0, 200, 0, 30)
    
    local label = Instance.new("TextButton", colorPicker.frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    
    local colorDisplay = Instance.new("Frame", colorPicker.frame)
    colorDisplay.Size = UDim2.new(0.3, 0, 1, 0)
    colorDisplay.Position = UDim2.new(0.7, 0, 0, 0)
    colorDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Дефолтный цвет
    
    label.MouseButton1Click:Connect(function()
        -- Простейшая логика выбра цвета
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        
        colorDisplay.BackgroundColor3 = Color3.fromRGB(r, g, b)
        colorPicker.value = Color3.fromRGB(r, g, b)
    end)
    
    return colorPicker
end

return UILibrary
