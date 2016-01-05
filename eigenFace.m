clean;
facePath = 'D:\Users\...\att_faces\s0\';
picNum = 30;

faceDatabase = [];
for i = 1:picNum
    faceName = [num2str(10+i) '.pgm'];
    I = imread([facePath faceName]);
%     figure, imshow(I)

    face = im2double(I);
    reduceRate = [1 1];
    reducedFace = reduceSample(face, reduceRate(1), reduceRate(2));
    reducedEqFace = histeq(reducedFace);
%     figure, imshow(reducedFace);
    
    faceCol = reducedEqFace(:);
    faceDatabase = [faceDatabase faceCol];
end

avgFaceCol = mean(faceDatabase, 2);
for i = 1:picNum
    faceDatabase(:,i) = faceDatabase(:,i) - avgFaceCol;
end

[u s v] = svd(faceDatabase);


k = 15;
u_reduced = u(:,1:k);
featureVector = zeros(k, picNum);
% 545-3/1104 hiroshi: test for scaled featureVector
scale = 5;
avgFaceOn = 1;
% % % % 

for i = 1:picNum
    eigenFace{i} = reshape(u(:,i), size(reducedFace));
%     figure, imshow(eigenFace{i},[]);
    
    featureVector(:, i) = scale*u_reduced'*faceDatabase(:,i);
    pcaFaceCol = u(:,1:k)*featureVector(:, i) + avgFaceOn*avgFaceCol;
    pcaFace{i} = reshape(pcaFaceCol, size(reducedFace));
%     figure, imshow(pcaFace{i});
end


%%%%%%% face recognition
testFace = imread([facePath '12.pgm']);
testFace = imnoise(testFace, 'gaussian', 0, 0);
% figure, imshow(testFace)
testEqFace = histeq(testFace);
% figure, imshow(testEqFace);
testFaceCol = im2double(testEqFace(:)) - avgFaceCol;
testFaceVector = u_reduced'*testFaceCol;

dis = zeros(picNum, 1);
sim = zeros(picNum, 1);
mdis = zeros(picNum, 1);

mahalanobis_C = cov(featureVector')'; % my representation: col.vectors represent each measurement data set, 
                                      %                    row.vectors represent different variables
for i = 1:picNum
    dis(i) = norm(testFaceVector - featureVector(:,i));
    sim(i) = dot(testFaceVector, featureVector(:,i)) / ( norm(testFaceVector)*norm(featureVector(:,i)) );
    mdis(i) = sqrt((testFaceVector - featureVector(:,i))'*inv(mahalanobis_C)*(testFaceVector - featureVector(:,i)));
end

dis
mdis
sim
% 
figure, plot(dis, '-o'), grid on;
figure, plot(mdis, '-o'), grid on;
figure, plot(sim, '-o'), grid on;
