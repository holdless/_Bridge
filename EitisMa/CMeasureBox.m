classdef CMeasureBox < handle
  properties
    mRoiBox;
    mRoiImage;
    mRoiRange;
    mBoxAxes;
    mEdgePos = struct('x', [], 'y', []);
    mProfile = struct('sumline', [], 'movavg', [], 'absGrad', []);
    mBoxColor;
    mEdgeColor;
    mAlgo;
    mMSize;
    mScale;
    mWhiteBandEdge = struct('left', [], 'right', []);
    mBandwidth;
    mAxis;
    mLER;
    mCursorPos = struct('x', [], 'y', []);
    
    mHole = struct('centroid', [], 'diameter', []);
    centroid = struct('x', [], 'y', []);
    diameter = struct('mean', [], 'max', [], 'min', []);
    
    mMeasureArea = struct('measPoint', [], 'sumLines', [], 'isLeft', [])    
    mDetectMethod = struct('isDarkHole', [], 'is2D', [], 'isMaxFiltered', [], 'threshold', [], 'method', [], 'smoothing', [],...
      'differential', [], 'BLStartPt', [], 'BLArea', []);
    threshold = struct('max', [], 'min', [], 'target', []);
    
%     mHole = struct('minimalArea', [], 'centers', [], 'boundaries', [], 'boundingBoxes', [], 'areas', []);
  end
 
  methods

    function getAxes(obj, boxAxes)
      obj.mBoxAxes = boxAxes;
    end
    
    function setAxesProperties(obj, imageAxis)
      obj.mAxis = imageAxis;
    end
    
    function setScale(obj, scale)
      obj.mScale = scale;
    end
    
    function setBox(obj, boxColor)
      axes(obj.mBoxAxes);
      rect = getrect;
      obj.mRoiBox = round(rect);
      obj.mBoxColor = boxColor;
    end
        
    function getBoxImage(obj, image)
      rect = obj.mRoiBox;
      obj.mRoiImage =  image(rect(2):(rect(2)+rect(4)), rect(1):(rect(1)+rect(3)) );
    end
    
%     function getSubEdge(obj)
%       % if using 'smart se or bse', bypass this function
%       if ~strcmp(obj.mAlgo, 'se') && ~strcmp(obj.mAlgo, 'bse')   
%         measPoints = obj.mMeasureArea.measPoints;
%         sumLines = obj.mMeasureArea.sumLines;
%         algo = obj.mAlgo;
%         
%         roiImage = obj.mRoiImage;
%         roiBox = obj.mRoiBox;
%         pixelNo = size(roiImage, 1);
%         if measPoints > pixelNo
%           measPoints = pixelNo;
%         end
%         reso = (pixelNo - 1)/(measPoints + 1);
%         maxSumLines = ceil(reso)*2;
%         if sumLines > maxSumLines
%           sumLines = maxSumLines;
%         end
%         N = 1:measPoints;
%         Cursor.y = 1 + N*reso;
%         
%         for cursorNo = 1:size(Cursor.y,2)
%           cursor_y = Cursor.y(cursorNo);
%           if ceil(cursor_y) == floor(cursor_y)
%             subRoi = roiImage((cursor_y-sumLines/2):(cursor_y+sumLines/2), :);
%             height = size((cursor_y-sumLines/2):(cursor_y+sumLines/2), 2);
%             ypos = roiBox(2)+cursor_y-1;
%             subBox = [roiBox(1), ypos-sumLines/2, roiBox(3), height-1];
%           else
%             subRoi = roiImage((ceil(cursor_y)-sumLines/2):(floor(cursor_y)+sumLines/2), :);
%             height = size((ceil(cursor_y)-sumLines/2):(floor(cursor_y)+sumLines/2), 2);
%             ypos = roiBox(2)+ceil(cursor_y)-1;
%             subBox = [roiBox(1), ypos-sumLines/2, roiBox(3), height-1];
%           end
%           subProfile = mean(subRoi);
%           
%           [cursorPos, movavg, absGrad] = getEdge(subProfile, subBox, algo, obj.mMeasureArea, obj.mDetectMethod);
%           obj.mCursorPos.x(cursorNo) = cursorPos.x;
%           obj.mCursorPos.y(cursorNo) = ypos;
%         end
%       end
%     end
    
    function showCursor(obj)
      % if using "smart se or bse", bypass this function
%       if (~strcmp(obj.mAlgo, 'se') && ~strcmp(obj.mAlgo, 'bse'))
        axes(obj.mBoxAxes)        
        if obj.mDetectMethod.is2D == 0
          plot(obj.mCursorPos.x, obj.mCursorPos.y, '+', 'color', 'y', 'linewidth', 0.7, 'MarkerSize', 4), hold on
        else
          if obj.mDetectMethod.isDarkHole == 1
            cursorColor = 'y';
          else
            cursorColor = 'b';
          end
          plot(obj.mCursorPos.x, obj.mCursorPos.y, '+', 'color', cursorColor, 'linewidth', 0.7, 'MarkerSize', 2), hold on
        end
        axis(obj.mAxis)
%       end
    end

    function drawBox(obj)
      axes(obj.mBoxAxes);
      rectangle('position', obj.mRoiBox, 'edgecolor', obj.mBoxColor) % green
      axis(obj.mAxis)
    end
    
    function showRoiImage(obj, roiAxes)
      axes(roiAxes);
%       imshow(  obj.mRoiImage, 'InitialMagnification','fit'   ), hold on
      imshow(  obj.mRoiImage, 'InitialMagnification',800   ), hold on
    end
        
    function setEdgeAlgo(obj, algo, measureArea, detectMethod)
      obj.mAlgo = algo;
      obj.mMeasureArea.measPoints = measureArea.measPoints;
      obj.mMeasureArea.sumLines = measureArea.sumLines;
      obj.mMeasureArea.isLeft = measureArea.isLeft;
      obj.mDetectMethod.mSize = detectMethod.mSize;
      obj.mDetectMethod.threshold = detectMethod.threshold;
      obj.mDetectMethod.isMaxFiltered = detectMethod.isMaxFiltered;
      obj.mDetectMethod.smoothing = detectMethod.smoothing;
      obj.mDetectMethod.differential = detectMethod.differential;
      obj.mDetectMethod.BLStartPt = detectMethod.BLStartPt;
      obj.mDetectMethod.BLArea = detectMethod.BLArea;
      obj.mDetectMethod.method = detectMethod.method;
      obj.mDetectMethod.is2D = detectMethod.is2D;
      obj.mDetectMethod.isDarkHole = detectMethod.isDarkHole;
    end
    
    function setEdgeProperties(obj, edgeColor)
      obj.mEdgeColor = edgeColor;
    end
        
    function computeLER(obj, kPixel)
      frac = 1;
      for i = 1:kPixel:size(obj.mRoiImage,1)
        if i+kPixel-1 < size(obj.mRoiImage,1)
          fraction = obj.mRoiImage(i:i+kPixel-1, :);
        else
          fraction = obj.mRoiImage(i:end, :);
        end
        
        sumline = mean(fraction);
%         obj.mFractionMean{i} = sumline;
        
        smootheredX = medfilt1(sumline, obj.mMSize);
        movavg = movmean( smootheredX, obj.mSmoothing);
        for j = 1:obj.mSmoothing
          try
            movavg(j) = movavg(obj.mSmoothing+1);
            movavg(end-obj.mSmoothing+j) = movavg(end-obj.mSmoothing);
          catch
            break;
          end
        end
        absGrad = abs(gradient( movavg));
                
        if strcmp(obj.mAlgo, 'bse')
          [c, idx] = max(absGrad);
        elseif strcmp(obj.mAlgo, 'se')
          [c, idx] = max(movavg);
        end
        
        edgePos(frac) = obj.mScale*(idx - 1);
      
        frac = frac + 1;
      end
      obj.mLER = std(edgePos);
      
    end
    
    function findEdge(obj)
      sumline = mean(obj.mRoiImage);
      obj.mProfile.sumline = sumline;
      
      if obj.mDetectMethod.is2D == 1
        hole = extractContour(obj.mRoiImage, obj.mDetectMethod.isDarkHole);
        if obj.mDetectMethod.isDarkHole == 1
          contourColor = 'b';
        else
          contourColor = 'y';
        end
        showContours(hole, obj.mRoiBox, obj.mBoxAxes, contourColor, 1);
        showContourCentroid(hole.center, obj.mRoiBox, 'r', 1);
        Vq = cartesian2polar(hole.center, obj.mRoiImage, obj.mRoiBox);
        [cursor.R, cursor.Theta] = getSubEdge(obj.mMeasureArea, obj.mDetectMethod, obj.mAlgo, Vq, [1, 1, size(Vq,2)-1, size(Vq,1)-1]);
        for i = 1:size(cursor.R, 2)
          [cursor.X(i), cursor.Y(i)] = polar2cartesian(cursor.R(i), cursor.Theta(i));
        end
        obj.mCursorPos.x = cursor.X + obj.mRoiBox(1) + hole.center(1) - 1;
        obj.mCursorPos.y = cursor.Y + obj.mRoiBox(2) + hole.center(2) - 1;
        
        obj.mHole.centroid.x = mean(obj.mCursorPos.x);
        obj.mHole.centroid.y = mean(obj.mCursorPos.y);

        showEdgeCentroid(obj.mHole.centroid, 'cyan', 1);

        diameterNo = size(obj.mCursorPos.x, 2);
        for i = 1:diameterNo/2
          A = [obj.mCursorPos.x(i), obj.mCursorPos.y(i)];
          B = [obj.mCursorPos.x(i+diameterNo/2), obj.mCursorPos.y(i+diameterNo/2)];
          diameters(i) = norm(A-B);
        end
        
        obj.mHole.area = hole.area;
        obj.mHole.diameter.mean = mean(diameters);
        obj.mHole.diameter.max = max(diameters);
        obj.mHole.diameter.min = min(diameters);
        
      else
        
        [obj.mEdgePos, obj.mProfile.movavg, obj.mProfile.absGrad] =...
          getEdge(sumline, obj.mRoiBox, obj.mAlgo, obj.mMeasureArea, obj.mDetectMethod);
%         if ~strcmp(obj.mAlgo, 'se') && ~strcmp(obj.mAlgo, 'bse')
          [obj.mCursorPos.x, obj.mCursorPos.y] = getSubEdge(obj.mMeasureArea, obj.mDetectMethod, obj.mAlgo, obj.mRoiImage, obj.mRoiBox);
          
          if obj.mDetectMethod.isMaxFiltered == 0
            obj.mEdgePos.x = mean(obj.mCursorPos.x);
          else
            a = sort(obj.mCursorPos.x);
            obj.mEdgePos.x = mean(a(2:end-1));
          end
%         end
      end
%       smootheredX = medfilt1(sumline, obj.mMSize);
%       movavg = movmean( smootheredX, obj.mSmoothing);
%       for i = 1:obj.mSmoothing
%         try
%           movavg(i) = movavg(obj.mSmoothing+1);
%           movavg(end-obj.mSmoothing+i) = movavg(end-obj.mSmoothing);
%         catch
%           break;
%         end
%       end
%       absGrad = abs(gradient( movavg));
%       
%       obj.mProfile.sumline = sumline;
%       obj.mProfile.movavg = movavg;
%       obj.mProfile.absGrad = absGrad;
%       
%       if strcmp(obj.mAlgo, 'bse')
%         [c, idx] = max(absGrad);
%       elseif strcmp(obj.mAlgo, 'se')
%         [c, idx] = max(movavg);
%       end
% 
%       obj.mEdgePos.x = obj.mRoiBox(1)+idx - 1;
%       obj.mEdgePos.y = obj.mRoiBox(2)+obj.mRoiBox(4)/2 - 1;
    end
    
    function showProfile(obj, roiAxes)
      axes(roiAxes)

      W = size(obj.mRoiImage, 2);
      H = size(obj.mRoiImage, 1);
      pt = 30;
      e = H/(pt+1);
      
      scale1 = .7*size(obj.mRoiImage, 1)/max(obj.mProfile.sumline);
      scale2 = .95*size(obj.mRoiImage, 1)/max(obj.mProfile.absGrad);
      plot(1:W, H - scale2*obj.mProfile.absGrad,...
        'linewidth', 1.5, 'color', 'yellow'), hold on
      plot(1:W, H - scale1*obj.mProfile.sumline,...
           1:W, H - scale1*obj.mProfile.movavg,'linewidth', 3), hold on;
         
      if strcmp(obj.mAlgo, 'se')
        pts = 1:H/pt:H+e;
        pts = pts(1:pt);
        plot(obj.mWhiteBandEdge.left*ones(1,pt), pts, 'r+', 'linewidth', 1), hold on
        plot(obj.mWhiteBandEdge.right*ones(1,pt), pts, 'r+', 'linewidth', 1), hold on
        text(0, 5, ['Bandwidth: ', num2str(obj.mBandwidth)], 'fontsize', 10, 'color', 'yellow');
      end
      
      text(0, 30, ['LER: ', num2str(obj.mLER)], 'fontsize', 10, 'color', 'yellow');

    end
    
    function measureWhiteBand(obj)
      if strcmp(obj.mAlgo, 'se')
        [centerVal, centerPos] = max(obj.mProfile.sumline);
        grad.leftSide = obj.mProfile.absGrad(1:centerPos-1);
        grad.rightSide = obj.mProfile.absGrad(centerPos+1:end);
        [val, obj.mWhiteBandEdge.left] = max(grad.leftSide);
        [val, obj.mWhiteBandEdge.right] = max(grad.rightSide);
        obj.mWhiteBandEdge.right = obj.mWhiteBandEdge.right + centerPos;
         obj.mBandwidth = obj.mScale*(obj.mWhiteBandEdge.right - obj.mWhiteBandEdge.left);
      end
    end
    
    function showEdge(obj)
      axes(obj.mBoxAxes)
      plot(obj.mEdgePos.x, obj.mEdgePos.y, '+', 'color', obj.mEdgeColor, 'linewidth', 1.5), hold on
      line( [obj.mEdgePos.x,obj.mEdgePos.x],...
            [obj.mRoiBox(2), obj.mRoiBox(2)+obj.mRoiBox(4)],...
            'color', obj.mEdgeColor, 'LineStyle', '-.');
      axis(obj.mAxis)
    end
        
  end
end

% % % % % % % % % % % % % % % % % % % % % 

% function [edgePos, movavg, absGrad] = getEdge(profile, mSize, smoothing, algo, roiBox, isLeft, threshold, method)
function [edgePos, movavg, absGrad] = getEdge(profile, roiBox, algo, measureArea, detectMethod)
smootheredX = medfilt1(profile, detectMethod.mSize);
movavg = movmean( smootheredX, detectMethod.smoothing);
for i = 1:detectMethod.smoothing
  try
    movavg(i) = movavg(detectMethod.smoothing+1);
    movavg(end-detectMethod.smoothing+i) = movavg(end-detectMethod.smoothing);
  catch
    break;
  end
end
[top.val, top.idx] = max(movavg);
% absGrad = abs(gradient(movavg));
% absGrad = abs(fivePtStencil(movavg));
absGrad = abs(nDiff(movavg, 5));


imbalance = 1; % 1:small Space, 0:small CD

if strcmp(algo, 'bse')
  [c, idx] = max(absGrad);
elseif strcmp(algo, 'se')
  [c, idx] = max(movavg);
elseif strcmp(algo, 'line')
  if measureArea.isLeft == 1
    if detectMethod.method == 1
      idx = searchB2T(movavg, top, detectMethod.threshold, imbalance);
    elseif detectMethod.method == 2
      idx = linearB2T(absGrad, detectMethod.BLStartPt, detectMethod.BLArea, top, movavg, imbalance);
    end
  else
    if detectMethod.method == 1
      idx = searchT2B(movavg, top, detectMethod.threshold, imbalance);
    elseif detectMethod.method == 2
      idx = linearT2B(absGrad, detectMethod.BLStartPt, detectMethod.BLArea, top, movavg, imbalance);
    end
  end
elseif strcmp(algo, 'space')
  if measureArea.isLeft == 0
    if detectMethod.method == 1
      idx = searchB2T(movavg, top, detectMethod.threshold, imbalance);
    elseif detectMethod.method ==  2
      idx = linearB2T(absGrad, detectMethod.BLStartPt, detectMethod.BLArea, top, movavg, imbalance);
    end
  else
    if detectMethod.method == 1
      idx = searchT2B(movavg, top, detectMethod.threshold, imbalance);
    elseif detectMethod.method == 2
      idx = linearT2B(absGrad, detectMethod.BLStartPt, detectMethod.BLArea, top, movavg, imbalance);
    end
  end
end

edgePos.x = roiBox(1)+idx - 1;
edgePos.y = roiBox(2)+roiBox(4)/2 - 1;
end

function idx = linearB2T(absGrad, BLStartPt, BLArea, top, movavg, imbalance)
[c, ii] = max(absGrad(1:top.idx));
idxm = ii - sign(BLStartPt)*(abs(BLStartPt) - 1);
idxb = idxm - (BLArea - 1);

movavgHalf = movavg(1:top.idx);
[bottom.val, bottom.idx] = min(movavgHalf);

% target = ( movavg(idxm) + movavg(idxb) ) / 2;
target = mean(movavg(idxb:idxm));

if imbalance == 1
  offset = 1;
elseif imbalance == 0
  offset = 0;
end
for i = bottom.idx:top.idx
  if movavgHalf(i) >= target
    idx = i - offset;
    break;
  end
end

end

function idx = linearT2B(absGrad, BLStartPt, BLArea, top, movavg, imbalance)
[c, ii] = max(absGrad(top.idx:end));
idxm = ii + sign(BLStartPt)*(abs(BLStartPt) - 1) + top.idx - 1;
idxb = idxm + (BLArea - 1);

movavgHalf = movavg(top.idx:end);
[bottom.val, bottom.idx] = min(movavgHalf);

% target = ( movavg(idxm) + movavg(idxb) ) / 2;
target = mean(movavg(idxm:idxb));


if imbalance == 1
  offset = 0;
elseif imbalance == 0
  offset = 1;
end
for i = top.idx:(top.idx+bottom.idx-1)
  if movavg(i) <= target
    idx = i - offset;
    break;
  end
end

end

function idx = searchT2B(movavg, top, threshold, imbalance)
movavgHalf = movavg(top.idx:end);
[bottom.val, bottom.idx] = min(movavgHalf);
target = threshold.target*(top.val - bottom.val) + bottom.val;

if imbalance == 1
  offset = 0;
elseif imbalance == 0
  offset = 1;
end
for i = top.idx:(top.idx+bottom.idx-1)
  if movavg(i) <= target
    idx = i - offset;
    break;
  end
end
end

function idx = searchB2T(movavg, top, threshold, imbalance)
movavgHalf = movavg(1:top.idx);
[bottom.val, bottom.idx] = min(movavgHalf);
target = threshold.target*(top.val - bottom.val) + bottom.val;

if imbalance == 1
  offset = 1;
elseif imbalance == 0
  offset = 0;
end
for i = bottom.idx:top.idx
  if movavgHalf(i) >= target
    idx = i - offset;
    break;
  end
end
end




function deri = nDiff(seq, n)
for i = 1:size(seq, 2)
  lobe = (n-1)/2;
  if i > lobe && i <= size(seq, 2)- lobe
    deri(i) = ( seq(i+lobe)-seq(i-lobe) ) / (n-1);
  else
    deri(i) = 0;
  end
end
end

function deri = fivePtStencil(seq)
for i = 1:size(seq, 2)
  if i > 2 && i < size(seq, 2)-1
    f1 = seq(i-2);
    f2 = -8*seq(i-1);
    f3 = 8*seq(i+1);
    f4 = -seq(i+2);
    deri(i) = (f1 + f2 + f3 + f4)/12;
  else
    deri(i) = 0;
  end
end
end

function [cursorx, cursory] = getSubEdge(measureArea, detectMethod, algo, roiImage, roiBox)
measPoints = measureArea.measPoints;
sumLines = measureArea.sumLines;

pixelNo = size(roiImage, 1);
if measPoints > pixelNo
  measPoints = pixelNo;
end

if detectMethod.is2D == 1
  reso = pixelNo/measPoints;
  N = 0:(measPoints-1);
else
  reso = (pixelNo - 1)/(measPoints + 1);
  N = 1:measPoints;
end
Cursor.y = 1 + N*reso;

maxSumLines = floor(reso)*2; % 2020.10.5 revise from ceil to floor
if sumLines > maxSumLines
  sumLines = maxSumLines;
end

for cursorNo = 1:size(Cursor.y,2)
  cursor_y = Cursor.y(cursorNo);
  if detectMethod.is2D == 1 && cursorNo == 1
    subRoi = roiImage(   [cursor_y:sumLines/2, (360-(sumLines/2-2)):360]   , :);
    height = size([cursor_y:sumLines/2, (360-(sumLines/2-2)):360], 2);
    ypos = roiBox(2)+cursor_y-1;
    subBox = [roiBox(1), ypos-sumLines/2, roiBox(3), height-1];
  elseif ceil(cursor_y) == floor(cursor_y)
    subRoi = roiImage((cursor_y-sumLines/2):(cursor_y+sumLines/2), :);
    height = size((cursor_y-sumLines/2):(cursor_y+sumLines/2), 2);
    ypos = roiBox(2)+cursor_y-1;
    subBox = [roiBox(1), ypos-sumLines/2, roiBox(3), height-1];
  else
    subRoi = roiImage((ceil(cursor_y)-sumLines/2):(floor(cursor_y)+sumLines/2), :);
    height = size((ceil(cursor_y)-sumLines/2):(floor(cursor_y)+sumLines/2), 2);
    ypos = roiBox(2)+ceil(cursor_y)-1;
    subBox = [roiBox(1), ypos-sumLines/2, roiBox(3), height-1];
  end
  subProfile = mean(subRoi);
  
  [cursorPos, movavg, absGrad] = getEdge(subProfile, subBox, algo, measureArea, detectMethod);
  cursorx(cursorNo) = cursorPos.x;
  cursory(cursorNo) = ypos;
end
end

function hole = extractContour(roiImage, isDarkHole)
BW = imbinarize(roiImage);
% BWe = medfilt2(BW);
% BWe = wiener2(medfilt2(BW));
BWe = medfilt2(medfilt2(BW));

if isDarkHole == 1
  BWe = not(BWe);
end

% figure
% subplot(1,2,1), imshow(BW)
% subplot(1,2,2), imshow(BWe)

[boundaries, L] = bwboundaries(BWe,'noholes');
stats = regionprops('table',BWe,'Centroid','boundingbox','area');
centers = stats.Centroid;
boundingBoxes = stats.BoundingBox;
areas = stats.Area;

for i = 1:size(centers, 1)
  minDis(i) = norm(centers(i,:) - 0.5*[size(roiImage,2), size(roiImage,1)]);
end

[c, idx] = min(minDis);
hole.center = centers(idx,:);
hole.boundingBox = boundingBoxes(idx,:);
hole.area = areas(idx);
hole.boundary = boundaries{idx};

end


function showContours(hole, roiBox, boxAxes, COLOR, LINEWIDTH)
axes(boxAxes)
plot(hole.boundary(:,2)+roiBox(1)-1, hole.boundary(:,1)+roiBox(2)-1, COLOR, 'LineWidth', LINEWIDTH)
end

function showContourCentroid(center, roiBox, COLOR, LINEWIDTH)
plot(center(1)+roiBox(1)-1, center(2)+roiBox(2)-1, '+', 'color', COLOR, 'linewidth', LINEWIDTH)
end

function showEdgeCentroid(centroid, COLOR, LINEWIDTH)
plot(centroid.x, centroid.y, '+', 'color', COLOR, 'linewidth', LINEWIDTH)
end

function Vq = cartesian2polar(center, roiImage, roiBox)
xc = center(1);
yc = center(2);
R = min(0.5*roiBox(3), 0.5*roiBox(4));

polarInfo = [];
for xi = 1:size(roiImage, 2)
  for yi = 1:size(roiImage, 1)
    x = xi - xc;
    y = yi - yc ;
    r = sqrt(x*x + y*y);
    if r <= R
      theta = atan2(y, x);
      if theta < 0
        theta = theta + 2*pi;
      end
      polarInfo = [polarInfo; xi,yi,r,theta*180/pi,double(roiImage(yi,xi))];
    end
  end
end
% interpolate grayscale in polar space
rq = 1:R;
tq = 1:360;
[Rq,Tq] = meshgrid(rq, tq);
Vq = griddata(polarInfo(:,3), polarInfo(:,4), polarInfo(:,5), Rq, Tq, 'v4');

% figure
% mesh(Rq,Tq,Vq)
% hold on
% plot3(polarInfo(:,3),polarInfo(:,4),polarInfo(:,5),'o')
% 
% figure
% imshow(Vq, [])
end

function [x, y] = polar2cartesian(r, theta)
x = r*cos(theta*pi/180);
y = r*sin(theta*pi/180);
end


% function [tot_mass, center] = centerOfInertia(A)
% A = double(A);
% tot_mass = sum(A(:));
% [ii,jj] = ndgrid(1:size(A,1),1:size(A,2));
% center = [sum(jj(:).*A(:))/tot_mass, sum(ii(:).*A(:))/tot_mass];
% end
