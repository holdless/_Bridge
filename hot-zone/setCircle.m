function f = setCircle(f, posx, posy, radius)
boundx = size(f,2);
boundy = size(f,1);
if posx >= boundx || posy >= boundy || posx < 0 || posy < 0
    errmsg = 'wrong posx/y'
    return
end

for col = 1:boundx
    for row = 1:boundy
        if (col - posx)^2 + (row - posy)^2 <= radius^2
            f(row, col) = 1;
        end
    end
end
