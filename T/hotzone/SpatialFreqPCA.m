clean;

spatialFreqReso = 512;
picNum = 8;
offset = 1;
principalComponetNo = 1;
isFake = 1;
isLogDisplay = 1;

for i = 1:picNum
    if isFake
        f{i} = zeros(30,30);
        
        % setRepeatedRect(f, posx, posy, lengthx, lengthy, freqx, freqy, pitchx, pitchy)
        f{i} = setRepeatedRect(f{i},...
            2+i*offset, 2+i*offset,... % pos
            1, 15,... % length
            3, 5,... % pitch
            3, 1); % freq
%         f{i} = setRepeatedRect(f{i},...
%             25-i*offset, 25-i*offset,... % pos
%             5, 1,... % length
%             1, 3,... % pitch
%             1, 3); % freq
    else
        imgPath = 'D:...\';
        imgName = ['hhh' num2str(i) '.PNG'];
        g = imread([imgPath imgName]);
        g = rgb2gray(g);
        f{i} = g(1:spatialFreqReso, 1:spatialFreqReso);
    end
                             
    figure (1)
    title('layout');
    subplot(picNum/2,2,i),
    imshow(f{i},'InitialMagnification','fit');

    F{i} = fft2(f{i},spatialFreqReso,spatialFreqReso);
%     Fs{i} = fftshift(F{i});
%     Fs{i} = abs(Fs{i});
    
    figure (2)
    title('L-invariance freq.');
    subplot(picNum/2,2,i);
    if isLogDisplay
        imshow(log(abs(fftshift(F{i}))+0.01*max(max(F{1}))),[],'InitialMagnification','fit');
    else
        imshow(abs(fftshift(F{i})), [],'InitialMagnification','fit');
    end
    colormap(jet); colorbar
end

%%%%%%%%%%%%%%%
absFreqDB = [];
orgFreqDB = [];
for i = 1:picNum
    absFreqDB = [absFreqDB abs(F{i}(:))];
    orgFreqDB = [orgFreqDB F{i}(:)];
end

pcaFace = layoutPCA(absFreqDB, picNum, size(F{1}), principalComponetNo, isLogDisplay);
