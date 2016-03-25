function f = setRepeatedRect(f, posx, posy, lengthx, lengthy, pitchx, pitchy, freqx, freqy)
boundx = size(f,2);
boundy = size(f,1);
if posx >= boundx || posy >= boundy || posx < 0 || posy < 0
    errmsg = 'wrong posx/y'
    return
end
if freqx <= 0 || freqy <= 0
    errmsg = 'wrong freqx/y'
    return
end

if freqx > 0 && pitchx > 0
    for i = 1:freqx
        for j = 1:freqy
            startx = (i-1)*pitchx + posx;
            endx = startx + lengthx;
            starty = (j-1)*pitchy + posy;
            endy = starty + lengthy;
            if endx > boundx
                endx = boundx;
            end
            if endy > boundy
                endy = boundy;
            end
            f(starty:endy, startx:endx) = 1;
        end
    end
end

