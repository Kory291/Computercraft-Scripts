networModemSide = "right"
turbineSide = "back"

rednet.open(networModemSide)
rednet.host("turbineControl", "turbineControllerSlave")
turbine = peripheral.wrap(turbineSide)

print("connecting")
turbineControllerMaster = rednet.lookup("turbineControl", "turbineControllerMaster")
while turbineControllerMaster == nil do
    turbineControllerMaster = rednet.lookup("turbineControl", "turbineControllerMaster")
end
print("connected")

turbineInfo = {state = nil, inductorEngaged = nil, energyProducedLastTick = nil, rotorSpeed = nil, fluidFlowRateMax = nil, fluidFlowRateLastTick = nil}
turbineCommands = {state = nil, inductorEngaged = nil}

function getTurbineStats()
    turbineInfo.state = turbine.getActive()
    turbineInfo.inductorEngaged = turbine.getInductorEngaged()
    turbineInfo.energyProducedLastTick = turbine.getEnergyProducedLastTick()
    turbineInfo.rotorSpeed = turbine.getRotorSpeed()
    turbineInfo.fluidFlowRateMax = turbine.getFluidFlowRateMax()
    turbineInfo.fluidFlowRateLastTick = turbine.getFluidFlowRate()
end

while true do
    getTurbineStats()
    os.sleep(math.random())
    rednet.send(turbineControllerMaster, turbineInfo,"turbineControl")
    sender, message, _ = rednet.receive("turbineControl", 2)
    if (message ~= nil) and (sender == turbineControllerMaster) then
        -- message equals turbineCommands
        if message.state ~= nil then
            turbine.setActive(message.state)
        end
        if message.inductorEngaged ~= nil then
            turbine.setInductorEngaged(message.inductorEngaged)
        end
    end
end