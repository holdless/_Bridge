classdef CMeasurePitch < handle
  properties
    mCenter = {struct('x', [], 'y', []), struct('x', [], 'y', [])};
    mPitch;
    mSetAxes;
    mPitchColor;
    mScale;
    mAxis;
  end
 
  methods
%     function obj = CMeasureBox()
%     end
    function getAxes(obj, setAxes)
      obj.mSetAxes = setAxes;
    end
    
    function setAxesProperties(obj, imageAxis)
      obj.mAxis = imageAxis;
    end
        
    function setScale(obj, scale)
      obj.mScale = scale;
    end
    
    function updateMeasurement(obj, edge1, edge2, edge3, edge4, repeatCnt)
      obj.mCenter{1}.x = round( (edge2.x + edge1.x)/2, 1);
      obj.mCenter{1}.y = round( (edge2.y + edge1.y)/2, 1);
      obj.mCenter{2}.x = round( (edge4.x + edge3.x)/2, 1);
      obj.mCenter{2}.y = round( (edge4.y + edge3.y)/2, 1);
      obj.mPitch = obj.mScale*(obj.mCenter{2}.x - obj.mCenter{1}.x)/repeatCnt;
    end
    
    function setColor(obj, posColor)
      obj.mPitchColor = posColor;
    end
        
    function setInfo(obj)
      axes(obj.mSetAxes)
      for i = 1:2
        text(obj.mCenter{i}.x, obj.mCenter{i}.y-50,...
          num2str(obj.mScale*obj.mCenter{i}.x), 'FontSize', 10, 'color', obj.mPitchColor);
      end
      text(obj.mPitch, obj.mCenter{1}.x + 50, obj.mCenter{1}.y-50,...
        num2str(obj.mPitch), 'FontSize', 20, 'color', obj.mPitchColor);
      axis(obj.mAxis)
    end
                   
    function showCenter(obj)
      axes(obj.mSetAxes)
      for i = 1:2
        plot(obj.mCenter{i}.x, obj.mCenter{i}.y, 'y+', 'linewidth', 2), hold on
        line( [obj.mCenter{i}.x, obj.mCenter{i}.x],...
          [obj.mCenter{i}.y - 50, obj.mCenter{i}.y + 50],...
          'color', obj.mPitchColor,'LineStyle','-.', 'linewidth', 1.5);
      end
      axis(obj.mAxis)
    end
        
  end
end
