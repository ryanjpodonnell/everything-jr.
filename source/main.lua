local data = { 0 }
local font = playdate.graphics.font.new('images/Nano Sans 2X')
local gfx  = playdate.graphics

playdate.display.setRefreshRate(50)

function clearScreen()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, 400, 240)
  gfx.setColor(gfx.kColorBlack)

  playdate.graphics.drawLine(0, 194, 400, 194)
  playdate.graphics.drawLine(0, 196, 400, 196)
  playdate.graphics.setFont(font)
  playdate.graphics.drawText('everything jr.', 0, 198)
end

function decreaseData(num)
  local value = data[1] + num

  if value < 0
  then
    data[1] = 65535
  else
    data[1] = value
  end
end

function drawBitString()
  local bitString = toBits(data[1])
  for i = 1, #bitString do
    local x = (i - 1) % 4
    local y = math.floor((i - 1) / 4)
    local scaledX = (x * 48) + 104
    local scaledY = y * 48

    if bitString[i] == 1
    then
      gfx.setColor(gfx.kColorBlack)
    else
      gfx.setColor(gfx.kColorWhite)
    end

    gfx.fillRect(scaledX, scaledY, 48, 48)
  end
end

function increaseData(num)
  local value = data[1] + num

  if value > 65535
  then
    data[1] = 0
  else
    data[1] = value
  end
end

function modifyData(num)
  if num > 0
  then
    increaseData(num)
  else
    decreaseData(num)
  end
end

function playdate.AButtonDown()
  modifyData(1)
end

function playdate.BButtonDown()
  modifyData(-1)
end

function playdate.cranked(change, acceleratedChange)
  modifyData(math.floor(acceleratedChange))
end

function playdate.deviceWillSleep()
  saveData()
end

function playdate.downButtonDown()
  data[1] = 0
end

function playdate.gameWillTerminate()
  saveData()
end

function playdate.upButtonDown()
  data[1] = math.random(0, 65535)
end

function playdate.update()
  if playdate.isCrankDocked()
  then
    modifyData(1)
  end

  drawBitString()
end

function readData()
  data = playdate.datastore.read()

  if data == nil
  then
    data = { 0 }
  end
end

function saveData()
  playdate.datastore.write(data)
end

function toBits(num)
  local bits = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  local i = 0

  while num > 0 do
    local rest = math.fmod(num, 2)
    bits[i + 1] = rest
    i = i + 1
    num = math.floor((num - rest) / 2)
  end

  return bits
end

clearScreen()
readData()
