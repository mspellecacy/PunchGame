module(..., package.seeall)
 
local dummyAd
local isAdVisible = false
local isAdOnTop = true;
local dummyTimer
local isAndroid = "Android" == system.getInfo("platformName")
 
local CW = display.contentWidth
local CH = display.contentHeight
local SOX = display.screenOriginX
local SOY = display.screenOriginY
 
local function round(n)
    return math.floor(n + 0.5)
end
 
local function adToFront()
    if dummyAd then
        dummyAd:toFront()
    end
end
 
local function showAd_Android(event)
    -- Is the url a remote call?
    if string.find(event.url, "android_ad.html", 1, false) then
        return true
    else
        system.openURL( string.gsub(event.url, "Corona:", "") )
        -- Refresh ad
        hideAd()
        showAd(isAdOnTop)
        return true
    end
end
 
local function showAd_Apple(event)
    -- Is the url a remote call?
    if string.find(event.url, "http://", 1, false) == 1 then
        -- Is it a call to the admob server?
        if string.find(event.url, "c.admob.com", 1, false) ~= nil then
            -- an actual click on an ad, so open in Safari
            system.openURL(event.url)
            -- Refresh ad
            hideAd()
            showAd(isAdOnTop)
        end
    else
        return true
    end
end
 
function showAd(onTop)
    if isAdVisible then
        if (isAdOnTop == onTop) then
            return
        else
            hideAd()
        end
    end
    isAdOnTop = onTop == true
    hideAd()
 
    local adfile = "apple_ad.html"
    local sizeX = 320
    local sizeY = 48
    local posX = (CW - sizeX) / 2
    -- round the Y position to remove the 1px gap
    -- between the bottom of the ad the bottom of the screen
    local posY = isAdOnTop and SOY or round(CH - SOY - sizeY)
 
    if isAndroid then
        adfile = "android_ad.html"
        native.showWebPopup(posX, posY, sizeX, sizeY, adfile,
            {
                baseUrl = system.ResourceDirectory,
                hasBackground = false,
                urlRequest = showAd_Android,
                autoCancel = false
            }
        )
 
    elseif system.getInfo("environment") == "simulator" then
        dummyAd = display.newRect(posX, posY, sizeX, sizeY)
        dummyTimer = timer.performWithDelay(1000, adToFront, 0)
    else
        native.showWebPopup(posX, posY, sizeX, sizeY, adfile,
            {
                baseUrl = system.ResourceDirectory,
                hasBackground = false,
                urlRequest = showAd_Apple,
                autoCancel = false
            }
        )
    end
    isAdVisible = true
end
 
function hideAd()
    native.cancelWebPopup()
    if dummyTimer then
        timer.cancel(dummyTimer)
        dummyTimer = nil
    end
    if dummyAd then
        dummyAd:removeSelf()
        dummyAd = nil
    end
    isAdVisible = false
end