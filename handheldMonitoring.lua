rednet.open("back")
maxRetries = 10
retries = 0
mainTerminal = term.current()
quarryInfoWindow = window.create(mainTerminal, 1, 1, 26, 3)
draconicReactorInfoWindow = window.create(mainTerminal, 1, 4, 26, 5)

while (rednet.lookup("quarryMonitoring") == nil) and (retries < maxRetries) do
    print("trying to connect with quarryMonitoringMaster")
    os.sleep(1)
    retries = retries + 1
end
if retries >= maxRetries then
    print("couldn't connect with quarryMonitoringMaster")
    os.sleep(5)
    shell.exit()
end
print("connections established")
os.sleep(5)
mainTerminal.clear()

maxX, maxY = mainTerminal.getSize()
runningPositionX = 1

function getDraconicReactorInfo()
    senderID, message, _ = rednet.receive("draconicReactorInfo", 10)
    draconicReactorInfoWindow.clear()
    draconicReactorInfoWindow.setCursorPos(1,2)
    if message ~= nil then
        if (message.usedFuel >= message.usedFuelLimit) or (message.fieldStrength <= message.fieldStrengthLimit) then
            draconicReactorInfoWindow.setBackgroundColor(colors.red)
        else
            draconicReactorInfoWindow.setBackgroundColor(colors.green)
        end
        formattedFieldStrength = string.format("%.4f", message.fieldStrength)
        formattedUsedFuel = string.format("%.4f", message.usedFuel)
    end
    draconicReactorInfoWindow.write("used fuel: " .. formattedUsedFuel .. " %")
    draconicReactorInfoWindow.setCursorPos(1, 3)
    draconicReactorInfoWindow.write("field strength: " .. formattedFieldStrength .. " %")
end

function getQuarryInfo()
    senderID, message, _ = rednet.receive("quarryMonitoring", 10)
    quarryInfoWindow.clear()
    quarryInfoWindow.setCursorPos(1,2)
    if message then
        quarryInfoWindow.setBackgroundColor(colors.green)
        quarryInfoWindow.write("Quarry: läuft")
    else
        quarryInfoWindow.setBackgroundColor(colors.red)
        quarryInfoWindow.write("Quarry: läuft nicht")  
    end
end

function printRunning()
    mainTerminal.setCursorPos(runningPositionX, maxY)
    mainTerminal.clearLine()
    mainTerminal.write("X")
    runningPositionX = runningPositionX + 1
    if runningPositionX > maxX then
        runningPositionX = 1
    end
end

while true do
    parallel.waitForAny(getDraconicReactorInfo, getQuarryInfo)
    printRunning()
end