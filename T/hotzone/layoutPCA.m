function pcaFace = layoutPCA(absFreqDB, picNum, freqSize, principalComponetNo, isLogDisplay)

avgFaceCol = mean(absFreqDB, 2);
for i = 1:picNum
    absFreqDB(:,i) = absFreqDB(:,i) - avgFaceCol;
end

[u s v] = svd(absFreqDB,0);


% principalComponetNo = 10;
u_reduced = u(:,1:principalComponetNo);
featureVector = zeros(principalComponetNo, picNum);
% 545-3/1104 hiroshi: test for scaled featureVector
scale = 1;
avgFaceOn = 1;
% % % % 

for i = 1:picNum
    eigenFace{i} = reshape(u(:,i), freqSize);
%     figure, imshow(eigenFace{i},[]);
figure (3)
title('eigen-freq');
subplot(picNum/2,2,i),
if isLogDisplay
    imshow(log(fftshift(abs(eigenFace{i})+0.01*max(max(abs(eigenFace{1}))))),[],'InitialMagnification','fit');
else
    imshow(abs(fftshift(eigenFace{i})),[],'InitialMagnification','fit');
end
colormap(jet); colorbar

    featureVector(:, i) = scale*u_reduced'*absFreqDB(:,i);
    pcaFaceCol = u(:,1:principalComponetNo)*featureVector(:, i) + avgFaceOn*avgFaceCol;
    pcaFace{i} = reshape(pcaFaceCol, freqSize);
%     figure, imshow(pcaFace{i});
figure (4)
title('pca-freq.');
subplot(picNum/2,2,i),
if isLogDisplay
    imshow(log(fftshift(abs(pcaFace{i})+0.01*max(max(abs(pcaFace{1}))))),[],'InitialMagnification','fit');
else
    imshow(fftshift(pcaFace{i}),[],'InitialMagnification','fit');
end
colormap(jet); colorbar

figure (5)
title('eigen-layout');
subplot(picNum/2,2,i),
imshow(fftshift(real(ifft2(eigenFace{i}))),[],'InitialMagnification','fit');
colormap(jet); colorbar

figure (6)
title('pca-layout');
subplot(picNum/2,2,i),
imshow(fftshift(real(ifft2(pcaFace{i}))),[-5000 5000],'InitialMagnification','fit');
colormap(jet); colorbar

end


% %%%%%%% face recognition
% testFace = imread([facePath '12.pgm']);
% testFace = imnoise(testFace, 'gaussian', 0, 0);
% % figure, imshow(testFace)
% testEqFace = histeq(testFace);
% % figure, imshow(testEqFace);
% testFaceCol = im2double(testEqFace(:)) - avgFaceCol;
% testFaceVector = u_reduced'*testFaceCol;

% dis = zeros(picNum, 1);
% sim = zeros(picNum, 1);
% mdis = zeros(picNum, 1);
% 
% mahalanobis_C = cov(featureVector')'; % my representation: col.vectors represent each measurement data set, 
%                                       %                    row.vectors represent different variables
% for i = 1:picNum
%     dis(i) = norm(testFaceVector - featureVector(:,i));
%     sim(i) = dot(testFaceVector, featureVector(:,i)) / ( norm(testFaceVector)*norm(featureVector(:,i)) );
%     mdis(i) = sqrt((testFaceVector - featureVector(:,i))'*inv(mahalanobis_C)*(testFaceVector - featureVector(:,i)));
% end
% 
% dis
% mdis
% sim
% % 
% figure, plot(dis, '-o'), grid on;
% figure, plot(mdis, '-o'), grid on;
% figure, plot(sim, '-o'), grid on;
