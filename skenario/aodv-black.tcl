# Simulation with AODV Routing Protocol
# Def‌ine Options

set val(chan)		Channel/WirelessChannel		;	# Channel Type
set val(prop)		Propagation/TwoRayGround	;	# Radio-Propagation Model
set val(netif)		Phy/WirelessPhy			;	# Network Interface Type
set val(mac)		Mac/802_11			;	# MAC Type
set val(ifq)		Queue/DropTail/PriQueue		;	# Interface Queue Type
set val(ll)		LL				;	# Link Layer Type
set val(ant)		Antenna/OmniAntenna		;	# Antenna Model
set val(ifqlen)		50				;	# Maximum Packets in IFQ
set val(nn)		10				;	# Number of Mobile Nodes
set val(rp)		AODV				;	# AODV Routing Protocol
set val(energymodel)	EnergyModel			;	# For Energy 
set val(initialenergy)	100				; 	# Initial Energy of node
set val(lm)		"off"				;	# log movement
set val(x)	    500				;	# X Dimension of Topography
set val(y)		500				;	# Y Dimension of Topography
set val(stop)		200				; 	# Time of Simulation end
set val(cp)             "traffic1"             ;# connection pattern file
set val(sc)             "scenario10.tcl"

set ns_	[new Simulator]				
set tracefd [open s-aodv2-black.tr w]
set namtrace [open s-aodv2-black.nam w]

#$ns_ use-newtrace	
$ns_ trace-all $tracefd

$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

Agent/AODV set num_nodes $val(nn)

# Setting up Topography Object

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

# Create nn mobilenodes [$val(nn)] and attach them to channel

set chan_1_ [new $val(chan)]

# Configure the nodes

$ns_ node-config 	-adhocRouting $val(rp) \
			-llType $val(ll) \
			-macType $val(mac) \
			-channel $chan_1_ \
			-ifqType $val(ifq) \
			-ifqLen $val(ifqlen) \
			-antType $val(ant) \
			-propType $val(prop) \
			-phyType $val(netif) \
			-topoInstance $topo \
			-agentTrace ON \
			-routerTrace ON \
			-macTrace ON \
			-movementTrace ON \

for {set i 0} {$i < $val(nn)} {incr i} {
set node_($i) [$ns_ node]
}

# Provide Initial Location of Mobile Nodes
puts "Loading connection pattern..."
source $val(cp)

puts "Loading scenario file..."

source $val(sc)
# Set a TCP connection between node_(0) and node_(1)

#Setup a TCP connection


# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {
# 30 defines the node size for nam
$ns_ initial_node_pos $node_($i) 100
}

$node_(0) color green
$ns_ at 0.0 "$node_(0) color green"
$ns_ at 0.0 "$node_(0) label Source"

$node_(8) color blue
$ns_ at 0.0 "$node_(8) color blue"
$ns_ at 0.0 "$node_(8) label Destination"

$node_(6) color red
$ns_ at 0.0 "$node_(6) color red"
$ns_ at 0.0 "$node_(6) label Attacker"

$ns_ at 0.0 "[$node_(6) set ragent_] hacker"

# $node_(5) color green
# $ns_ at 0.0 "$node_(5) color green"
# $ns_ at 0.0 "$node_(5) label Source"

# $node_(8) color blue
# $ns_ at 0.0 "$node_(8) color blue"
# $ns_ at 0.0 "$node_(8) label Destination"

# $node_(4) color red
# $ns_ at 0.0 "$node_(4) color red"
# $ns_ at 0.0 "$node_(4) label Attacker"

# $ns_ at 0.0 "[$node_(4) set ragent_] hacker"

# Telling nodes when the simulation ends

for {set i 0} {$i < $val(nn)} { incr i} {
$ns_ at $val(stop) "$node_($i) reset"
}

# Ending nam and the simulation

# This method of calling print-stats should not be used as it should be called everytime with a node's id 
# However it shall do the same work
# $ns_ at 100.00 "[$node_(1) agent 255] print-stats"

$ns_ at 200.01 "puts \"end simulation\" ; $ns_ halt"

proc stop {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace
#exec nam aodv.nam &
}

$ns_ run
