classdef CMeasureFov < handle
  properties
    mPos = {struct('x', [], 'y', []),...
            struct('x', [], 'y', [])};
    mCd = {struct('mean', [], 'sigma', []),...
            struct('mean', [], 'sigma', [])};
    mOvl;
    mCdColorSet;
    mPosColorSet;
    mScale;
    mAxis;
  end
 
  methods
        
    function setAxesProperties(obj, imageAxis)
      obj.mAxis = imageAxis;
    end
    
    function updateMeasurement(obj, measurePair)
      for layer = 1:2
        cdSum = 0;
        posSum.x = 0;
        posSum.y = 0;
        pairs = size(measurePair{layer}, 2);
        cdSet = zeros(pairs, 1);
        for i = 1:pairs
          cdSum = cdSum + measurePair{layer}{i}.mCd.mean;
          cdSet(i) = measurePair{layer}{i}.mCd.mean;
          posSum.x = posSum.x + measurePair{layer}{i}.mCenter.x;
          posSum.y = posSum.y + measurePair{layer}{i}.mCenter.y;
        end
        obj.mCd{layer}.mean = cdSum/pairs;
        obj.mCd{layer}.sigma = std(cdSet);
        obj.mPos{layer}.x = posSum.x/pairs;
        obj.mPos{layer}.y = posSum.y/pairs;
      end
      obj.mOvl = obj.mPos{1}.x - obj.mPos{2}.x;
    end
    
    function setColor(obj, cdColor, posColor)
      obj.mCdColorSet = cdColor;
      obj.mPosColorSet = posColor;
    end
    
    function setScale(obj, scale)
      obj.mScale = scale;
    end
    
    function setInfo(obj, textAxes)
      axes(textAxes{1})
      cla;
      set(textAxes{1}, 'visible', 'off');
      text(0, 10,...
        ['CD: ' num2str(obj.mScale*obj.mCd{1}.mean)], 'FontSize', 10, 'color', obj.mCdColorSet{1});
      text(0, 35,...
        ['std: ' num2str(obj.mScale*obj.mCd{1}.sigma)], 'FontSize', 10, 'color', obj.mCdColorSet{1});
      text(0, 60,...
        ['pos: ' num2str(obj.mScale*obj.mPos{1}.x)], 'FontSize', 10, 'color', obj.mPosColorSet{1});
      text(0, 160,...
        ['OVL: ' num2str(obj.mScale*obj.mOvl)], 'FontSize', 10, 'color', 'yellow');
      axis(obj.mAxis)
      
      axes(textAxes{2})
      cla;
      set(textAxes{2}, 'visible', 'off');
      text(0, 85,...
        ['CD: ' num2str(obj.mScale*obj.mCd{2}.mean)], 'FontSize', 10, 'color',  obj.mCdColorSet{2});
      text(0, 110,...
        ['sdt: ' num2str(obj.mScale*obj.mCd{2}.sigma)], 'FontSize', 10, 'color',  obj.mCdColorSet{2});
      text(0, 135,...
        ['pos: ' num2str(obj.mScale*obj.mPos{2}.x)], 'FontSize', 10, 'color',  obj.mPosColorSet{2});
      axis(obj.mAxis)
    end
                   
    function showCenterCursor(obj, drawAxes)
      axes(drawAxes{1})
      cla;
      plot(obj.mPos{1}.x, obj.mPos{1}.y, '+', 'color', obj.mPosColorSet{1}, 'linewidth', 3), hold on
      set(gca, 'visible', 'off');
      axis(obj.mAxis)
      
      axes(drawAxes{2})
      cla;
      plot(obj.mPos{2}.x, obj.mPos{2}.y, '+', 'color', obj.mPosColorSet{2}, 'linewidth', 3), hold on
      set(gca, 'visible', 'off');
      axis(obj.mAxis)
    end
            
  end
end
