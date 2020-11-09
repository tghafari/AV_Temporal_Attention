function condMat = responseCollector(condMat,trial,audStartTime,firstPress,lastPress)
%condMat = responseCollector(condMat,trial,audStartTime,partDevCod)
%collects response key and response time in condition matrix
%audStartTime -> auditory presentation onset
%KB -> keyCodes related to the response box
%partDevCod -> participant's device code
%afterVisSecs -> time after visual stimulus presentation

condMat(trial,11) = find(firstPress);
condMat(trial,12) = max(firstPress)-audStartTime(trial,1);
condMat(trial,22) = find(lastPress);
condMat(trial,23) = max(firstPress)-audStartTime(trial,1);

KbQueueFlush;

end
