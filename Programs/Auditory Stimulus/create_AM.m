function [AM_sig, trigger]=create_AM(stimfreqs,p,dur_stim,sf,trgNo)
a=1; %amp
ma=stimfreqs;
t=1/sf;
numpts=dur_stim*sf;
nnoise=rand(1,numpts);
nnoise=nnoise-.5;
nnoise=nnoise*2;

%Preallocation
y=nan(1,numpts);
yyy=nan(1,numpts);

for n=1:numpts
    y(n)=a*(1+p*sin(2.*pi*ma*n*t-pi/2));%envelope
    yyy(n)=a*(1+p*sin(2.*pi*ma*n*t-pi/2))/(1+p);%envelope
end
AM_sig=nnoise.*yyy;
 
triggerdur=2; %ms
triggerdur=triggerdur/1000;
numtrgpoints=round(triggerdur*sf);
trg=ones(1,numtrgpoints);
 
assrtigger=AM_sig*0;
trigger=trgNo*[trg,assrtigger(1:length(assrtigger)-numtrgpoints)];
  
end