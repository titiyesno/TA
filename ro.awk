BEGIN {
        ro = 0;
}
 
$0 ~/^s.* RTR/ {
        ro++ ;
}
 
END {
        printf("Routing Overhead : %d\n",ro);
}
 