BEGIN {
        sendLine = 0;
        recvLine = 0;
}
 
{
	event = $1;
	node_id = $3;
	message = $4;

	if(event == "s" && message == "AGT" && node_id = "_0_"){
		sendLine++;
	}
	else if(event == "r" && message == "AGT" && node_id = "_3_"){
		recvLine++;
	}
}
 
END {
        printf "cbr s:%d r:%d, r/s Ratio:%.4f \n", sendLine, recvLine, (recvLine/sendLine);
}
 