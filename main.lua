require "tools"

function love.load()
    love.graphics.setDefaultFilter( "nearest", "nearest", 1 )

    sx = love.graphics.getWidth() / 180
    sy = love.graphics.getHeight() / 320

    asset = {
        pitch = love.graphics.newImage("img/pitch.png"),
        player = love.graphics.newImage("img/player.png"),
        ball = love.graphics.newImage("img/ball.png")
    }

    player = {}
    for i = 1, 5 do
        player[i] = {
            x = love.math.random(20, 160),
            y = love.math.random(10, 110),
            xv = 0,
            yv = 0,
            dead = false,
            team = 1
        }
    end

    for i = 6, 10 do
        player[i] = {
            x = love.math.random(20, 160),
            y = love.math.random(200, 300),
            xv = 0,
            yv = 0,
            dead = false,
            team = 2
        }
    end

    ball = {
        x = 180/2,
        y = 320/2,
        xv = 0,
        yv = 0
    }

    game = {
        turn = 1,
        score1 = 0,
        score2 = 0,
        bx = 0, -- for drawing arrow when player movement occurs
        by = 0,
        selP = -1,
        movesLeft = 3 -- selected player
    }
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(sx,sy)
    love.graphics.draw(asset.pitch) -- draws the pitch, this should always be the background

    if love.mouse.isDown(1) then
        cx, cy = love.mouse.getPosition( )
        cx = cx/sx
        cy = cy/sy
        love.graphics.line(game.bx,game.by,cx,cy)
    end

    for i,v in pairs(player) do
        if v.team == 1 then
            love.graphics.setColor(0.4,0,0)
        else
            love.graphics.setColor(0,0,0.4)
        end

        love.graphics.draw(asset.player,v.x,v.y)
    end



    love.graphics.draw(asset.ball,ball.x,ball.y)

    love.graphics.setColor(1,1,1)

    love.graphics.print(game.score1.." - "..game.score2.."\n"..game.movesLeft.." moves left player "..game.turn)

    love.graphics.pop()
end

function love.update(dt)
    for i,v in pairs(player) do
        local dragX = math.abs(v.xv*1.5)*dt
        local dragY = math.abs(v.yv*1.5)*dt
        v.x = v.x + v.xv*dt
        v.y = v.y + v.yv*dt
        if v.x > 180-asset.player:getWidth() or v.x < 1 then v.xv = -v.xv end
        if v.y > 320-asset.player:getHeight() or v.y < 1 then v.yv = -v.yv end

        if v.xv > 0 then v.xv = v.xv - dragX else v.xv = v.xv + dragX end
        if v.yv > 0 then v.yv = v.yv - dragY else v.yv = v.yv + dragY end

        if distanceFrom(v.x+asset.player:getWidth()/2, v.y+asset.player:getHeight()/2, ball.x+asset.ball:getWidth()/2, ball.y+asset.ball:getHeight()/2) < asset.ball:getWidth()+2 then
            ball.xv = ball.xv + v.xv
            ball.yv = ball.yv + v.yv
        end
        player[i] = v
    end

    ball.x = ball.x + ball.xv*dt
    ball.y = ball.y + ball.yv*dt
    if ball.x > 180-asset.ball:getWidth() or ball.x < 1 then ball.xv = -ball.xv end
    if ball.y > 320-asset.ball:getHeight() or ball.y < 1 then ball.yv = -ball.yv end
    local dragX = math.abs(ball.xv)*dt
    local dragY = math.abs(ball.yv)*dt
    if ball.xv > 0 then ball.xv = ball.xv - dragX else ball.xv = ball.xv + dragX end
    if ball.yv > 0 then ball.yv = ball.yv - dragY else ball.yv = ball.yv + dragY end
end

function love.mousepressed(x,y,button)
    x = x / sx
    y = y / sy

    for i,v in pairs(player) do
        if v.team == game.turn and x > v.x and x < v.x + asset.player:getWidth() and y > v.y and y < v.y + asset.player:getHeight() then
            game.bx = x
            game.by = y
            game.selP = i
            v.xv = 0
            v.yv = 0
            player[i] = v
        end
    end
end

function love.mousereleased(x,y,button)
    x = x / sx
    y = y / sy
    local limit = 75
    for i,v in pairs(player) do
        if v.team == game.turn and game.selP == i then
            v.xv = game.bx - x
            if v.xv > limit then v.vx = limit end
            if v.xv < -limit then v.vx = -limit end

            v.yv = game.by - y
            if v.yv > limit then v.yv = limit end
            if v.yv < -limit then v.yv = -limit end

            game.movesLeft = game.movesLeft - 1
            if game.movesLeft == 0 then
                if game.turn == 1 then game.turn = 2
                else game.turn = 1 end
                game.movesLeft = 3
            end

            player[i] = v
        end
    end
end