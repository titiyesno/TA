BEGIN{
	sum_delay = 0;
	count = 0;
}
{
	event = $1;
	type = $4;
	packet_id = $6;
	time = $2;
	count++;

	if(type == "AGT" && event == "s"){
		start[packet_id] = time;
	}
	else if(type == "AGT" && event == "r"){
		end[packet_id] = time;
	}

	if(end[packet_id] != 0){
		delay = end[packet_id] - start[packet_id];
		sum_delay += delay;
	}
	
}
END{
	printf("Average end to end delay : %lf \n",sum_delay/count);
}