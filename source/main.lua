local changes = {}
local data    = {}
local font    = playdate.graphics.font.new('images/Nano Sans 2X')
local gfx     = playdate.graphics

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
  for i = 1, #data do
    local value = data[i] + num

    if value < 0
    then
      num = -1

      data[i] = value + 65536
      changes[i] = true
    else
      data[i] = value
      changes[i] = true
      return
    end
  end
end

function drawBitString(data, iterator)
  local startingPixel = (iterator - 1) * 16

  local bitString = toBits(data)
  for i = 1, #bitString do
    local x = (startingPixel + i - 1) % 8
    local y = math.floor((startingPixel + i - 1) / 8)
    local scaledX = (x * 24) + 104
    local scaledY = y * 24

    if bitString[i] == 1
    then
      gfx.setColor(gfx.kColorBlack)
    else
      gfx.setColor(gfx.kColorWhite)
    end

    gfx.fillRect(scaledX, scaledY, 24, 24)
  end
end

function increaseData(num)
  for i = 1, #data do
    local value = data[i] + num

    if value > 65535
    then
      num = 1

      data[i] = value - 65536
      changes[i] = true
    else
      data[i] = value
      changes[i] = true
      return
    end
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
  for i = 1, #data do
    data[i] = 0
    changes[i] = true
  end
end

function playdate.gameWillTerminate()
  saveData()
end

function playdate.upButtonDown()
  for i = 1, #data do
    data[i] = math.random(0, 65535)
    changes[i] = true
  end
end

function playdate.update()
  if playdate.isCrankDocked()
  then
    modifyData(1)
  end

  for i = 1, #data do
    if changes[i] == true
    then
      drawBitString(data[i], i)
      changes[i] = false
    end
  end
end

function readData()
  data = playdate.datastore.read()

  if data == nil
  then
    data = { 0, 0, 0, 0 }
  end

  changes = { true, true, true, true }
end

function saveData()
  playdate.datastore.write(data)
end

function toBits(num)
  local bits = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
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
