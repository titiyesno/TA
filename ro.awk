BEGIN {
        ro = 0;
}
 
$0 ~/^s.* RTR/ {
	if($23 != "(HELLO)"){
		ro++ ;
	}
    
}
 
END {
        printf("Routing Overhead : %d\n",ro);
}
 