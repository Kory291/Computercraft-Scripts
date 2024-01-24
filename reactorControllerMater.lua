monitorSide = "right"
modemSide = "back"

monitor = peripheral.wrap(monitorSide)
rednet.open(modemSide)
rednet.host("reactorControl", "reactorControllerMaster")
rednet.host("turbineControl", "turbineControllerMaster")
reactorControllerSlave = rednet.lookup("reactorControl", "reactorControllerSlave")
print("connect")
while reactorControllerSlave == nil do
    reactorControllerSlave = rednet.lookup("reactorControl", "reactorControllerSlave")
end
turbineControllerSlave = rednet.lookup("turbineControl", "turbineControllerSlave")
while turbineControllerSlave == nil do
    turbineControllerSlave = rednet.lookup("turbineControl", "turbineControllerSlave")
end

print("connection built up")
reactorInfo = {state = nil, fuelAmount = nil, wasteAmount, fuelConsumedLastTick = nil, remainingTimeMin = nil}
turbineInfo = {state = nil, inductorEngaged = nil, energyProducedLastTick = nil, rotorSpeed = nil, fluidFlowRateMax = nil, fluidFlowRateLastTick = nil}

maxX, maxY = monitor.getSize()
turbinePos = maxX/2+2

function printMask()
    monitor.clear()
    for i=1,maxY do
        monitor.setCursorPos(maxX/2, i)
        monitor.write("|")
    end
    monitor.setCursorPos(maxX/4-2, 1)
    monitor.write("reactor:")
    monitor.setCursorPos(3*maxX/4-2, 1)
    monitor.write("turbine:")
    
    -- write for reactor
    monitor.setCursorPos(1, 2)
    monitor.write("state: ")
    monitor.setCursorPos(1, 3)
    monitor.write("remaining fuel:")
    monitor.setCursorPos(1,5)
    monitor.write("fuel comsumption:")
    monitor.setCursorPos(1,7)
    monitor.write("remaining time:")
    --write for turbine
    monitor.setCursorPos(turbinePos, 2)
    monitor.write("state: ")
    monitor.setCursorPos(turbinePos, 3)
    monitor.write("inductor engaged:")
    monitor.setCursorPos(turbinePos, 5)
    monitor.write("energy output:")
    monitor.setCursorPos(turbinePos, 7)
    monitor.write("steam flow:")
    monitor.setCursorPos(turbinePos, 9)
    monitor.write("max steam flow:")
    monitor.setCursorPos(turbinePos, 11)
    monitor.write("rotor speed:")
end

function receiveCommands()
    local sender, message, protocol = rednet.receive(1)
    if protocol ~= nil then
        if protocol == "reactorControl" and sender == reactorControllerSlave then
            reactorInfo = message              
        elseif protocol == "turbineControl" and sender == turbineControllerSlave then
            turbineInfo = message
        end
    end
end

function handleUserInput()
    local turbineCommands = {state = nil, inductorEngaged = nil}
    local event, side, x, y = os.pullEvent("monitor_touch")
    if ((1 <= x) and (x <= maxX/2-1)) and (y == 2) then 
        if reactorInfo ~= nil then
            rednet.send(reactorControllerSlave, {reactorState = not reactorInfo.state}, "reactorControl")
        end
    end

    if ((turbinePos <= x) and (x <= maxX)) and (y == 2) then
        if turbineInfo ~= nil then
            turbineCommands.state = not turbineInfo.state
        end
    end
    if ((turbinePos <= x) and (x <= maxX)) and (y == 4) then
        if turbineInfo ~= nil then
            turbineCommands.inductorEngaged = not turbineInfo.inductorEngaged
        end
    end
    rednet.send(turbineControllerSlave, turbineCommands, "turbineControl")
end

function printData()
    -- reactorData
    monitor.setCursorPos(8, 2)
    if reactorInfo.state ~= nil then
        if reactorInfo.state == true then
            monitor.setBackgroundColor(colors.green)
            monitor.write("active")
        else
            monitor.setBackgroundColor(colors.red)
            monitor.write("inactive")
        end
        monitor.setBackgroundColor(colors.black)
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(3, 4)
    if reactorInfo.fuelAmount ~= nil then
        monitor.write(reactorInfo.fuelAmount .. " mb")
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(3, 6)
    if reactorInfo.fuelConsumedLastTick ~= nil then
        local formattedComsumption = string.format("%.2f", reactorInfo.fuelConsumedLastTick)
        monitor.write(formattedComsumption .. " mb/tick")
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(3, 8)
    if reactorInfo.remainingTimeMin ~= nil then
        local formattedTime = string.format("%.2f", reactorInfo.remainingTimeMin) 
        monitor.write(formattedTime .. " min")
    else
        monitor.write("n.a.")
    end

    --turbineData
    monitor.setCursorPos(turbinePos + 7, 2)
    if turbineInfo.state ~= nil then
        if turbineInfo.state == true then
            monitor.setBackgroundColor(colors.green)
            monitor.write("active")
        else
            monitor.setBackgroundColor(colors.red)
            monitor.write("inactive")
        end
        monitor.setBackgroundColor(colors.black)
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(turbinePos + 2, 4)
    if turbineInfo.inductorEngaged ~= nil then
        if turbineInfo.inductorEngaged == true then
            monitor.setBackgroundColor(colors.green)
            monitor.write("engaged")
        else
            monitor.setBackgroundColor(colors.red)
            monitor.write("not engaged")
        end
        monitor.setBackgroundColor(colors.black)
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(turbinePos + 2, 6)
    if turbineInfo.energyProducedLastTick ~= nil then
        local energyOutput = turbineInfo.energyProducedLastTick / 1000
        local formattedEnergyOutput = string.format("%.4f", energyOutput)
        monitor.write(formattedEnergyOutput .. " kRF")
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(turbinePos + 2, 8)
    if turbineInfo.fluidFlowRateLastTick ~= nil then
        local formattedFluidFlowRateLastTick = string.format("%.2f", turbineInfo.fluidFlowRateLastTick)
        monitor.write(formattedFluidFlowRateLastTick .. " mb/tick")
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(turbinePos + 2, 10)
    if turbineInfo.fluidFlowRateMax ~= nil then
        local formattedFlowRate = string.format("%.2f", turbineInfo.fluidFlowRateMax)
        monitor.write(formattedFlowRate .. " mb/tick")
    else
        monitor.write("n.a.")
    end

    monitor.setCursorPos(turbinePos + 2, 12)
    if turbineInfo.rotorSpeed ~= nil then
        local formattedRotorSpeed = string.format("%.2f", turbineInfo.rotorSpeed)
        monitor.write(formattedRotorSpeed .. " rpm")
    else
        monitor.write("n.a.")
    end
end

while true do
    returned_function = parallel.waitForAny(receiveCommands, handleUserInput)
    printMask()
    printData()
end