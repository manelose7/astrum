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
    window.frame.Size = UDim2.new(0, 430, 0, 500)
    window.frame.Position = UDim2.new(0.5, -215, 0.5, -250)
    window.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    window.frame.Visible = true  -- Изначально открыто
    
    -- Заголовок окна
    local titleFrame = Instance.new("Frame", window.frame)
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local titleText = Instance.new("TextButton", titleFrame)
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.Text = title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.BackgroundTransparency = 1
    
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
