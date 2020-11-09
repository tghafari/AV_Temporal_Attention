clear aa; 
aa=zeros(50,9);
% for ii=1:48 
%     aa(ii,1)=condMat(ii+1,13)-condMat(ii,13); %commanded aud SOA == condmat 4
%     aa(ii,2)=condMat(ii+1,14)-condMat(ii,14); %commanded vis SOA == condmat 6
%     aa(ii,3)=condMat(ii+1,15)-condMat(ii,15); %duration of each trial
%     aa(ii,1)=condMat(ii,4); 
%     aa(ii,2)=condMat(ii,6);
%     aa(ii,6)=condMat(ii,13);
%     aa(ii,3)=audStartTime(ii+1,1)-audStartTime(ii,1); %=real Aud SOA
%     aa(ii,4)=0; %aa(ii,1)-aa(ii+1,5); % probably equals condMat 15? or condMat(ii-1,13)
%     aa(ii,5)=visPresTime(ii+1,1)-visPresTime(ii,1);  %=real Vis SOA
%     aa(ii,6)=vblVisOff(ii+1,1)-vblVisOff(ii,1);
%     aa(ii,7)=visPresTime(ii,1)-vblVisOff(ii,1);
% end
aa(:,1)=condMat(1:50,4); 
aa(1:end-1,2)=diff(audStartTime(1:50,1));
aa(1:end-1,3)=aa(2:end,1)-aa(1:end-1,2); 
aa(:,4)=audStartTime(1:50,1);
aa(:,5)=condMat(1:50,6); 
aa(1:end-1,6)=diff(visPresTime(1:50,1));
aa(1:end-1,7)=aa(2:end,5)-aa(1:end-1,6); 
aa(:,8)=visPresTime(1:50,1);
aa(:,9)=vblVisOff(1:50,1)-visPresTime(1:50,1);
aa(:,10)=condMat(1:50,20);
aa(:,11)=condMat(1:50,21);


% aa(1:end-1,8)=aa(1:end-1,3)-aa(2:end,4); 
%  aa(1:end-1,13)=aa(1:end-1,2)-aa(2:end,4);
%  aa(1:end-1,14)=aa(1:end-1,9)-aa(2:end,4);
%  aa(:,15)=audStartTime(1:49,1);
%  aa(1:end-1,16)=audStartTime(1:48,1)+aa(2:end,5); %this is correctly equal to condMat(:,13)
%  aa(:,17)=aa(:,3)-condMat(1:49,19);
%  aa(:,18)=aa(:,5)-aa(:,4);
%  aa(:,19)=sign(aa(:,18));
% bb=aa(aa(:,19)<0,12);
% cc=aa(aa(:,19)>0,12);
% b=aa(aa(:,19)<0,14);
% c=aa(aa(:,19)>0,14);

%  aa(:,8)=abs(aa(:,8)); aa(:,12)=abs(aa(:,12));
 
 %it looks like visual stimulus appeares on time with at most 50ms delay
 %auditory stimulus has delays up to 660ms, it is when the auditory
 %stimulus changes to toBeDetected sound condMat(condMat(:,8)==1,8)
 %sometimes visual also varies 
 %OVERALL timings are not reliable
 
 %Whenever visualSOA is longer than audSOA, aud is delayed.
 %whenevr audSOA is longer thatn visSOA, vis is delayed
 %!!!!because it waits until the longest duration for each trial is
 %passed!!!
 





