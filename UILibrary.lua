local UILibrary = {}
UILibrary.__index = UILibrary

-- Цветовая палитра
local COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 35),
    BACKGROUND_LIGHT = Color3.fromRGB(40, 40, 45),
    PRIMARY = Color3.fromRGB(52, 152, 219),     -- Яркий синий
    PRIMARY_HOVER = Color3.fromRGB(73, 173, 239),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 210),
    ACCENT_GREEN = Color3.fromRGB(46, 204, 113),
    ACCENT_GREEN_HOVER = Color3.fromRGB(67, 224, 133),
    ACCENT_GRAY = Color3.fromRGB(100, 100, 110)
}

-- Функция для создания тени
local function CreateShadow(parent)
    local shadow = Instance.new("Frame", parent)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.ZIndex = parent.ZIndex - 1
    return shadow
end

-- Базовый конструктор компонента
function UILibrary.new(parent: Instance): Component
    local self = setmetatable({}, UILibrary)
    self.frame = Instance.new("Frame", parent)
    self.frame.BackgroundColor3 = COLORS.BACKGROUND
    self.frame.BorderSizePixel = 0
    self.frame.Size = UDim2.new(1, 0, 0, 50)
    
    -- Добавляем мягкую тень
    local shadow = CreateShadow(self.frame)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    
    self.value = nil
    self.enabled = false
    return self
end

-- Создание Toggle компонента
function UILibrary.createToggle(parent: Instance, text: string): Component
    local toggle = UILibrary.new(parent)
    toggle.frame.Size = UDim2.new(1, 0, 0, 50)
    toggle.frame.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
    
    local textButton = Instance.new("TextButton", toggle.frame)
    textButton.Text = text
    textButton.Size = UDim2.new(1, -70, 1, 0)
    textButton.Position = UDim2.new(0, 10, 0, 0)
    textButton.BackgroundTransparency = 1
    textButton.Font = Enum.Font.GothamSemibold
    textButton.TextSize = 14
    textButton.TextColor3 = COLORS.TEXT_PRIMARY
    textButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleIndicator = Instance.new("Frame", toggle.frame)
    toggleIndicator.Size = UDim2.new(0, 40, 0, 25)
    toggleIndicator.Position = UDim2.new(1, -55, 0.5, -12)
    toggleIndicator.BackgroundColor3 = COLORS.ACCENT_GRAY
    toggleIndicator.BorderSizePixel = 0
    
    local toggleHandle = Instance.new("Frame", toggleIndicator)
    toggleHandle.Size = UDim2.new(0, 20, 0, 20)
    toggleHandle.Position = UDim2.new(0, 2, 0.5, -10)
    toggleHandle.BackgroundColor3 = COLORS.TEXT_PRIMARY
    toggleHandle.BorderSizePixel = 0
    
    toggle.TextButton = textButton
    toggle.ToggleIndicator = toggleIndicator
    toggle.ToggleHandle = toggleHandle
    
    textButton.MouseButton1Click:Connect(function()
        toggle.enabled = not toggle.enabled
        
        if toggle.enabled then
            toggleIndicator.BackgroundColor3 = COLORS.ACCENT_GREEN
            toggleHandle.Position = UDim2.new(1, -22, 0.5, -10)
        else
            toggleIndicator.BackgroundColor3 = COLORS.ACCENT_GRAY
            toggleHandle.Position = UDim2.new(0, 2, 0.5, -10)
        end
    end)
    
    return toggle
end

-- Создание Slider компонента
function UILibrary.createSlider(parent: Instance, text: string, minValue: number, maxValue: number): Component
    local slider = UILibrary.new(parent)
    slider.frame.Size = UDim2.new(1, 0, 0, 70)
    slider.frame.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
    
    local textButton = Instance.new("TextButton", slider.frame)
    textButton.Text = text
    textButton.Size = UDim2.new(1, -120, 0, 30)
    textButton.Position = UDim2.new(0, 10, 0, 5)
    textButton.BackgroundTransparency = 1
    textButton.Font = Enum.Font.GothamSemibold
    textButton.TextSize = 14
    textButton.TextColor3 = COLORS.TEXT_PRIMARY
    textButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueText = Instance.new("TextButton", slider.frame)
    valueText.Text = tostring(minValue)
    valueText.Size = UDim2.new(0, 60, 0, 30)
    valueText.Position = UDim2.new(1, -70, 0, 5)
    valueText.BackgroundTransparency = 1
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextSize = 12
    valueText.TextColor3 = COLORS.TEXT_SECONDARY
    
    local sliderBar = Instance.new("Frame", slider.frame)
    sliderBar.Size = UDim2.new(1, -80, 0, 10)
    sliderBar.Position = UDim2.new(0, 10, 1, -25)
    sliderBar.BackgroundColor3 = COLORS.ACCENT_GRAY
    sliderBar.BorderSizePixel = 0
    
    local sliderHandle = Instance.new("Frame", sliderBar)
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new(0, 0, 0.5, -10)
    sliderHandle.BackgroundColor3 = COLORS.PRIMARY
    sliderHandle.BorderSizePixel = 0
    
    slider.TextButton = textButton
    slider.ValueText = valueText
    slider.SliderBar = sliderBar
    slider.SliderHandle = sliderHandle
    
    local currentValue = minValue
    
    local function updateSlider(value)
        currentValue = math.max(minValue, math.min(maxValue, value))
        local percentage = (currentValue - minValue) / (maxValue - minValue)
        sliderHandle.Position = UDim2.new(percentage, -10, 0.5, -10)
        valueText.Text = string.format("%.2f", currentValue)
        slider.value = currentValue
    end
    
    local UserInputService = game:GetService("UserInputService")
    local isDragging = false
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            local relativePosition = input.Position.X - sliderBar.AbsolutePosition.X
            local percentage = relativePosition / sliderBar.AbsoluteSize.X
            updateSlider(minValue + percentage * (maxValue - minValue))
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativePosition = input.Position.X - sliderBar.AbsolutePosition.X
            local percentage = relativePosition / sliderBar.AbsoluteSize.X
            updateSlider(minValue + percentage * (maxValue - minValue))
        end
    end)
    
    return slider
end

-- Создание кнопки с кастомизацией
function UILibrary.createButton(parent: Instance, text: string, callback: () -> ()): Component
    local button = UILibrary.new(parent)
    button.frame.Size = UDim2.new(1, 0, 0, 50)
    
    local textButton = Instance.new("TextButton", button.frame)
    textButton.Size = UDim2.new(1, -20, 1, -10)
    textButton.Position = UDim2.new(0, 10, 0, 5)
    textButton.Text = text
    textButton.TextColor3 = COLORS.TEXT_PRIMARY
    textButton.BackgroundColor3 = COLORS.PRIMARY
    textButton.Font = Enum.Font.GothamSemibold
    textButton.TextSize = 14
    textButton.BorderSizePixel = 0
    
    textButton.MouseButton1Click:Connect(callback or function() end)
    
    -- Эффекты наведения и нажатия
    textButton.MouseEnter:Connect(function()
        textButton.BackgroundColor3 = COLORS.PRIMARY_HOVER
    end)
    
    textButton.MouseLeave:Connect(function()
        textButton.BackgroundColor3 = COLORS.PRIMARY
    end)
    
    textButton.MouseButton1Down:Connect(function()
        textButton.BackgroundTransparency = 0.5
    end)
    
    textButton.MouseButton1Up:Connect(function()
        textButton.BackgroundTransparency = 0
    end)
    
    return button
end

-- Создание выпадающего списка
function UILibrary.createDropdown(parent: Instance, text: string, options: {string}): Component
    local dropdown = UILibrary.new(parent)
    dropdown.frame.Size = UDim2.new(1, 0, 0, 50)
    
    local mainButton = Instance.new("TextButton", dropdown.frame)
    mainButton.Size = UDim2.new(1, -20, 1, -10)
    mainButton.Position = UDim2.new(0, 10, 0, 5)
    mainButton.Text = text
    mainButton.TextColor3 = COLORS.TEXT_PRIMARY
    mainButton.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
    mainButton.Font = Enum.Font.GothamSemibold
    mainButton.TextSize = 14
    mainButton.BorderSizePixel = 0
    
    local dropdownList = Instance.new("Frame", dropdown.frame)
    dropdownList.Size = UDim2.new(1, -20, 0, 0)
    dropdownList.Position = UDim2.new(0, 10, 1, 5)
    dropdownList.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
    dropdownList.Visible = false
    dropdownList.BorderSizePixel = 0
    
    -- Создание списка опций
    for i, optionText in ipairs(options) do
        local option = Instance.new("TextButton", dropdownList)
        option.Size = UDim2.new(1, 0, 0, 40)
        option.Position = UDim2.new(0, 0, 0, (i-1) * 40)
        option.Text = optionText
        option.TextColor3 = COLORS.TEXT_SECONDARY
        option.BackgroundColor3 = COLORS.BACKGROUND
        option.Font = Enum.Font.GothamMedium
        option.TextSize = 12
        option.BorderSizePixel = 0
        
        option.MouseButton1Click:Connect(function()
            mainButton.Text = optionText
            dropdownList.Visible = false
            dropdown.value = optionText
        end)
        
        option.MouseEnter:Connect(function()
            option.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
        end)
        
        option.MouseLeave:Connect(function()
            option.BackgroundColor3 = COLORS.BACKGROUND
        end)
    end
    
    mainButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        dropdownList.Size = UDim2.new(1, -20, 0, #options * 40)
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

-- Создание системы уведомлений
function UILibrary.createNotificationSystem(parent: Instance): Component
    local notificationSystem = UILibrary.new(parent)
    notificationSystem.frame.Size = UDim2.new(1, 0, 1, 0)
    notificationSystem.frame.BackgroundTransparency = 1
    notificationSystem.frame.ZIndex = 100  -- Высокий приоритет отображения
    
    -- Контейнер для уведомлений
    local notificationsContainer = Instance.new("Frame", notificationSystem.frame)
    notificationsContainer.Size = UDim2.new(1, 0, 1, 0)
    notificationsContainer.BackgroundTransparency = 1
    notificationsContainer.Name = "NotificationsContainer"
    
    -- Функция создания уведомления
    function notificationSystem:Notify(params)
        local title = params.Title or "Уведомление"
        local content = params.Content or ""
        local duration = params.Duration or 3
        local image = params.Image or 4483345998  -- Дефолтная иконка
        
        -- Создаем фрейм уведомления
        local notification = Instance.new("Frame", notificationsContainer)
        notification.Size = UDim2.new(0, 300, 0, 80)
        notification.Position = UDim2.new(1, 10, 1, -100)  -- Начальная позиция за пределами экрана
        notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notification.BorderSizePixel = 0
        
        -- Иконка уведомления
        local icon = Instance.new("ImageButton", notification)
        icon.Size = UDim2.new(0, 60, 0, 60)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.Image = "rbxassetid://" .. tostring(image)
        icon.BackgroundTransparency = 1
        
        -- Текст уведомления
        local titleText = Instance.new("TextButton", notification)
        titleText.Size = UDim2.new(0.7, -70, 0, 30)
        titleText.Position = UDim2.new(0, 80, 0, 10)
        titleText.Text = title
        titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleText.BackgroundTransparency = 1
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.TextSize = 16
        
        local contentText = Instance.new("TextButton", notification)
        contentText.Size = UDim2.new(0.7, -70, 0, 30)
        contentText.Position = UDim2.new(0, 80, 0, 40)
        contentText.Text = content
        contentText.TextColor3 = Color3.fromRGB(200, 200, 200)
        contentText.BackgroundTransparency = 1
        contentText.TextXAlignment = Enum.TextXAlignment.Left
        contentText.TextSize = 14
        
        -- Анимация появления
        local function animateNotification()
            local tweenInfo = TweenInfo.new(
                0.5,  -- Время анимации
                Enum.EasingStyle.Quad,  -- Стиль анимации
                Enum.EasingDirection.Out
            )
            
            local tween = game:GetService("TweenService"):Create(notification, tweenInfo, {
                Position = UDim2.new(1, -310, 1, -100)
            })
            tween:Play()
            
            -- Автоматическое закрытие
            task.delay(duration, function()
                local hideTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
                    Position = UDim2.new(1, 10, 1, -100)
                })
                hideTween:Play()
                
                -- Удаление после анимации
                hideTween.Completed:Connect(function()
                    notification:Destroy()
                end)
            end)
        end
        
        animateNotification()
        
        return notification
    end
    
    return notificationSystem
end

-- Создание главного окна с глобальным управлением
function UILibrary.createMainWindow(parent: Instance, title: string): Component
    local window = UILibrary.new(parent)
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui", parent)
    screenGui.Name = "UILibraryMainGui"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    window.frame.Parent = screenGui
    window.frame.Size = UDim2.new(0, 680, 0, 400)  -- Обновленный размер
    window.frame.Position = UDim2.new(0.5, -340, 0.5, -200)  -- Обновленная позиция
    window.frame.BackgroundColor3 = COLORS.BACKGROUND
    window.frame.BorderSizePixel = 0
    window.frame.Visible = true
    
    -- Добавляем мягкую тень
    local shadow = CreateShadow(window.frame)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    
    -- Заголовок окна
    local titleFrame = Instance.new("Frame", window.frame)
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundColor3 = COLORS.BACKGROUND_LIGHT
    titleFrame.BorderSizePixel = 0
    
    local titleText = Instance.new("TextButton", titleFrame)
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.Text = title
    titleText.TextColor3 = COLORS.TEXT_PRIMARY
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 16
    
    -- Контейнер для контента
    local contentFrame = Instance.new("Frame", window.frame)
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    
    -- Создаем систему уведомлений
    local notificationSystem = UILibrary.createNotificationSystem(window.frame)
    notificationSystem.frame.Position = UDim2.new(0, 0, 0, 0)
    
    -- Добавляем возможность перетаскивания
    local isDragging = false
    local dragStart
    local startPos
    
    titleText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = window.frame.Position
        end
    end)
    
    titleText.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Глобальное управление открытием/закрытием
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            window.frame.Visible = not window.frame.Visible
        end
    end)
    
    -- Расширяем объект дополнительными методами
    function window:AddComponent(component)
        component.frame.Parent = contentFrame
        return component
    end
    
    -- Добавляем метов уведомлений
    function window:Notify(params)
        return notificationSystem:Notify(params)
    end
    
    return window
end

return UILibrary
