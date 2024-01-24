reactorSide = "back"
modemSide = "top"

usedFuelLimit = 0.9
fieldStrengthLimit = 0.05

reactor = peripheral.wrap(reactorSide)
rednet.open(modemSide)
rednet.host("draconicReactorInfo", "draconicReactorControllerMaster")

while true do
    reactorInfo = reactor.getReactorInfo()
    usedFuel = reactorInfo.fuelConversion / reactorInfo.maxFuelConversion
    fieldStrength = reactorInfo.fieldStrength / reactorInfo.maxFieldStrength
    print("used fuel: " .. usedFuel)
    if (usedFuel >= usedFuelLimit) or (fieldStrength <= fieldStrengthLimit) then
        reactor.stopReactor()
        print("shutting down reactor")
    end
    rednet.broadcast({usedFuel = usedFuel, fieldStrength = fieldStrength, usedFuelLimit = usedFuelLimit, fieldStrengthLimit = fieldStrengthLimit}, "draconicReactorInfo")
    os.sleep(60)
end