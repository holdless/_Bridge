function points = parametricLine(w, bounds)
xmin = bounds(1);
xmax = bounds(2);
ymin = bounds(3);
ymax = bounds(4);

x0 = -w(3)/w(1);
y0 = -w(3)/w(2);
vx = -x0;
vy = y0;

s = [];
% xmax
t = (xmax - x0)/vx;
y_xmax = 0 + t*vy;
if (y_xmax >= ymin && y_xmax <= ymax)
    s = [s; [xmax, y_xmax]];
end
% xmin
t = (xmin - x0)/vx;
y_xmin = 0 + t*vy;
if (y_xmin >= ymin && y_xmin <= ymax)
    s = [s; [xmin, y_xmin]];
end
% ymax
t = (ymax)/vy;
x_ymax = x0 + t*vx;
if (x_ymax >= xmin && x_ymax <= xmax)
    s = [s; [x_ymax, ymax]];
end
% ymin
t = (ymin)/vy;
x_ymin = x0 + t*vx;
if (x_ymin >= xmin && x_ymin <= xmax)
    s = [s; [x_ymin, ymin]];
end
points = s;
