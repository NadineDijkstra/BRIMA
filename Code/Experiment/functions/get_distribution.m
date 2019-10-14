close all
contrastRange = -6:0.1:3;
B_range = [2 6 12];
nB = length(B_range);
v_range = [0.1 1 5 10];
nv = length(v_range);

counter = 0;
figure;
clear output

for Bidx = 1:nB
    B = B_range(Bidx);
    for vidx = 1:nv
        v = v_range(vidx);
        counter = counter + 1;

        for xidx = 1:length(contrastRange)
            x = contrastRange(xidx);
            output(xidx,vidx,Bidx) = generalized_logistic_function(x,...
                                          B,... % B = growth rate
                                          0,...% A = lower asymptote
                                          1,...% K = upper asymptote
                                          v,...% v = defines asymptote to which the function grows
                                          1,...% Q = Y(0)
                                          1,...% C = typically is 1
                                          0);% M 
                                      
        end
    end
    subplot(nB,1,Bidx),plot(output(:,:,Bidx))
    title(sprintf('growth rate (B) at %d',B))
    legend('0.1','1', '5', '10')
end

keyboard
