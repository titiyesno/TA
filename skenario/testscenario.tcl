# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

##################################################################
# Modified by Mohit P. Tahiliani and Gaurav Gupta		 #
# Department of Computer Science and Engineering		 #
# N.I.T.K., Surathkal				 		 #
# tahiliani.nitk@gmail.com					 #
# www.mohittahiliani.blogspot.com				 #
##################################################################

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     10                          ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      1700                        ;# X dimension of topography
set val(y)      1700                        ;# Y dimension of topography
set val(stop)   200.0                      ;# time of simulation end
set val(sc)     "scenario.tcl"

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns_ [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open testscenario.tr w]
$ns_ trace-all $tracefile

#Open the NAM trace file
set namfile [open testscenario.nam w]
$ns_ namtrace-all $namfile
$ns_ namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns_ node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      OFF \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 7 nodes
for {set i 0} {$i < $val(nn)} {incr i} {
set node_($i) [$ns_ node]
}

source $val(sc)

for {set i 0} {$i < $val(nn)} {incr i} {
# 30 defines the node size for nam
$ns_ initial_node_pos $node_($i) 100
}

# Node 5 is given RED Color and a label- indicating it is a Blackhole Attacker
# $n5 color red
# $ns at 0.0 "$n5 color red"
# $ns at 0.0 "$n5 label Attacker"

# Node 0 is given GREEN Color and a label - acts as a Source Node
$node_(0) color green
$ns_ at 0.0 "$node_(0) color green"
$ns_ at 0.0 "$node_(0) label Source"

# Node 3 is given BLUE Color and a label- acts as a Destination Node
$node_(1) color blue
$ns_ at 0.0 "$node_(1) color blue"
$ns_ at 0.0 "$node_(1) label Destination"

#===================================
#    	Set node 5 as attacker    	 
#===================================
#$ns at 0.0 "[$n5 set ragent_] hacker"

#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp0
set null1 [new Agent/Null]
$ns_ attach-agent $node_(1) $null1
$ns_ connect $udp0 $null1
$udp0 set packetSize_ 1500

#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ null
$ns_ at 1.0 "$cbr0 start"
$ns_ at 200.0 "$cbr0 stop"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns_ flush-trace
    close $tracefile
    close $namfile
    exec nam blackhole.nam &
    exit 0
}

for {set i 0} {$i < $val(nn)} { incr i} {
$ns_ at $val(stop) "$node_($i) reset"
}

$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "finish"
$ns_ at $val(stop) "puts \"done\" ; $ns_ halt"
$ns_ run
