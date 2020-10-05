classdef CMeasurePair < handle
  properties
    mCenter = struct('x', [], 'y', []);
    mCd = struct('mean', [], 'max', [], 'min', []);
    mArea;
        
    mPairAxes;
    mCdColor;
    mPosColor;
    mScale;
    mAxis;
  end
 
  methods
%     function obj = CMeasureBox()
%     end
    function getAxes(obj, pairAxes)
      obj.mPairAxes = pairAxes;
    end
    
    function setAxesProperties(obj, imageAxis)
      obj.mAxis = imageAxis;
    end
        
    function updateMeasurement(obj, edge1, edge2)
      obj.mCd.mean = floor(edge2.x) - ceil(edge1.x); % 2020.9.21 hiroshi: here's the fucking Hitachi's detail setting (trial & error the I got... fuck)
      obj.mCenter.x = round( (edge2.x + edge1.x)/2, 1);
      obj.mCenter.y = round( (edge2.y + edge1.y)/2, 2);
    end
    
    function updateMeasurement_2D(obj, hole)
      obj.mCd.mean = hole.diameter.mean;
      obj.mCd.max = hole.diameter.max;
      obj.mCd.min = hole.diameter.min;
      obj.mCenter.x = hole.centroid.x;
      obj.mCenter.y = hole.centroid.y;
      obj.mArea = hole.area;
    end
    
    function setColor(obj, cdColor, posColor)
      obj.mCdColor = cdColor;
      obj.mPosColor = posColor;
    end
    
    function setScale(obj, scale)
      obj.mScale = scale;
    end
    
    function setInfo(obj)
      axes(obj.mPairAxes)
      text(obj.mCenter.x-30, obj.mCenter.y-30,...
        num2str(obj.mScale*obj.mCd.mean), 'FontSize', 10, 'color', obj.mCdColor);
      text(obj.mCenter.x, obj.mCenter.y-50,...
        num2str(obj.mScale*obj.mCenter.x), 'FontSize', 10, 'color', obj.mPosColor);
      axis(obj.mAxis)
    end
        
    function showCenterCursor(obj)
      axes(obj.mPairAxes)
      plot(obj.mCenter.x, obj.mCenter.y, 'y+', 'linewidth', 2), hold on
      line( [obj.mCenter.x, obj.mCenter.x],...
            [obj.mCenter.y - 50, obj.mCenter.y + 50],...
            'color', obj.mPosColor,'LineStyle','-.', 'linewidth', 1.5);
      axis(obj.mAxis)
    end
        
  end
end
