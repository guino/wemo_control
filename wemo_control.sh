#!/bin/bash
#
# WeMo Control Script
# 
# Original author: rich@netmagi.com
#
# Modified 7/13/2014 by Donald Burr
# email: <dburr@DonaldBurr.com>
# web: <http://DonaldBurr.com>
#
# Modified 05/12/2014 by Jack Lawry
# email: <jack@jacklawry.co.uk>
# web: <http://www.jacklawry.co.uk>
#
# Modified 31/05/2015 by Wagner Oliveira
# * Fixed Port parameter and added Support for WeMo Link LED Bulbs
# email: <wbbo@hotmail.com>
# web: <http://guino.home.insightbb.com>
#
# Usage: wemo IP_ADDRESS[:PORT] ON|OFF|TOGGLE|GETSTATE|GETSIGNALSTRENGTH|GETFRIENDLYNAME
#    or: wemo IP_ADDRESS[:PORT] LINK [LIST|NAME ON [0-255]|OFF]

if [ "$1" = "" ]; then
    echo "Usage: wemo IP_ADDRESS[:PORT] ON|OFF|TOGGLE|GETSTATE|GETSIGNALSTRENGTH|GETFRIENDLYNAME"
    echo "   or: wemo IP_ADDRESS[:PORT] LINK [LIST|NAME ON [0-255]|OFF]"
	exit 1
fi

IP=$1
CMD=`echo $2 | tr '[a-z]' '[A-Z]'`

PORT=0
IPHASPORT=$(echo $IP | grep :)

if [ "$IPHASPORT" == "" ]; then

	for PTEST in 49154 49152 49153 49155
	do
		PORTTEST=$(curl -s -m 1 $IP:$PTEST | grep "404")
		if [ "$PORTTEST" != "" ]; then
			PORT=$PTEST
			break
		fi
 	done

	if [ $PORT = 0 ]; then
		echo "Cannot find a port"
		exit
	fi

	echo "INFO: Connected to" $1":"$PORT

else

 	PORT=$(echo $IP | awk -F : '{print $2}')
	IP=$(echo $IP | awk -F : '{print $1}')
	echo "Using provided port: $PORT"

fi

if [ "$CMD" = "GETSTATE" ]; then 
	STATE=`curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 | 
	grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1 | sed 's/0/OFF/g' | sed 's/1/ON/g'`
	if [ "$STATE" = "OFF" ]; then
		exit 0
	elif [ "$STATE" = "ON" ]; then
		exit 1
	else
		exit 2
	fi
elif [ "$CMD" = "TOGGLE" ]; then 
	STATE=`curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 | 
	grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1 | sed 's/0/OFF/g' | sed 's/1/ON/g'`
	if [ "$STATE" = "OFF" ]; then
		# echo "ITS OFF - TURNING ON"
		curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
		grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
		exit
	elif [ "$STATE" = "ON" ]; then
		# echo "ITS ON - TURNING OFF"
		curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
		grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
		exit
	else
		# echo "UNKNOWN"
		exit
	fi
elif [ "$CMD" = "ON" ]; then
	curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
	grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
elif [ "$CMD" = "OFF" ]; then
	curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
	grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
elif [ "$CMD" = "GETSIGNALSTRENGTH" ]; then
	curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetSignalStrength\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetSignalStrength xmlns:u="urn:Belkin:service:basicevent:1"><GetSignalStrength>0</GetSignalStrength></u:GetSignalStrength></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
	grep "<SignalStrength"  | cut -d">" -f2 | cut -d "<" -f1
elif [ "$CMD" = "GETFRIENDLYNAME" ]; then
	curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetFriendlyName\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetFriendlyName xmlns:u="urn:Belkin:service:basicevent:1"><FriendlyName></FriendlyName></u:GetFriendlyName></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
	grep "<FriendlyName"  | cut -d">" -f2 | cut -d "<" -f1
elif [ "$CMD" = "LINK" ]; then
	# Get Unique Device Number and List of Devices/IDs
	UDN=$(curl -s -m 1 http://$IP:$PORT/setup.xml | grep UDN | awk -F'>|<' '{print $3}')
	DEVS=$(curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#GetEndDevices\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetEndDevices xmlns:u="urn:Belkin:service:bridge:1"><ReqListType>SCAN_LIST</ReqListType><DevUDN>'$UDN'</DevUDN></u:GetEndDevices></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 | awk '{ gsub("&gt;", "\n"); print }')
	if [ "$3" == "LIST" ]; then
		echo "$DEVS" | grep "GroupName\|FriendlyName" | awk -F "&" '{ print $1 }' | grep -v -e "^$"
	else
		GROUPNAMES=$(echo "$DEVS" | grep -iE '(/GroupID|/GroupName)' | awk -F "&" '{print $1}')
		BULBNAMES=$(echo "$DEVS" | grep -iE '(/FriendlyName|/DeviceID)' | awk -F "&" '{print $1}')
		ID=$(echo "$DEVS" | grep -iE '(/GroupID|/GroupName|/FriendlyName|/DeviceID)' | awk -F "&" '{print $1}' | awk 'NR%2{a=$0;next}{print $0 "@"a;}' | grep "$3" | awk -F @ '{print $2}')
		if [ "$ID" == "" ]; then
			echo "$3 was not found."
			exit 254
		fi
		ISGROUP=$(echo "$GROUPNAMES" | grep "$ID")
		if [ "$ISGROUP" != "" ]; then
			ISGROUP="YES"
		else
			ISGROUP="NO"
		fi
		if [ "$4" == "ON" ]; then
			LEVEL=255
			if [ "$5" != "" ]; then
				LEVEL=$5
			fi
			# Send ON command
			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#SetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceStatusList>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;DeviceStatus&gt;&lt;DeviceID&gt;'$ID'&lt;/DeviceID&gt;&lt;CapabilityID&gt;10008&lt;/CapabilityID&gt;&lt;CapabilityValue&gt;'$LEVEL':0&lt;/CapabilityValue&gt;&lt;IsGroupAction&gt;'$ISGROUP'&lt;/IsGroupAction&gt;&lt;/DeviceStatus&gt;</DeviceStatusList></u:SetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
			UPDATESTATUS=1
		elif [ "$4" == "OFF" ]; then
			# Send OFF Command
			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#SetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceStatusList>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;DeviceStatus&gt;&lt;DeviceID&gt;'$ID'&lt;/DeviceID&gt;&lt;CapabilityID&gt;10008&lt;/CapabilityID&gt;&lt;CapabilityValue&gt;0:0&lt;/CapabilityValue&gt;&lt;IsGroupAction&gt;'$ISGROUP'&lt;/IsGroupAction&gt;&lt;/DeviceStatus&gt;</DeviceStatusList></u:SetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
			UPDATESTATUS=1
		elif [ "$4" == "TOGGLE" ]; then
			# Determine if device IS ON
			ISON=$(echo "$DEVS" | grep -iE '(/GroupCapabilityValues|/GroupName|/CurrentState|/FriendlyName)' | awk -F "&" '{print $1}' | awk 'NR%2{a=$0;next}{print a","$0;}' | grep "$3" | awk -F "," '{print $2}')
			LEVEL=$(echo "$DEVS" | grep -iE '(/GroupCapabilityValues|/GroupName|/CurrentState|/FriendlyName)' | awk -F "&" '{print $1}' | awk 'NR%2{a=$0;next}{print a","$0;}' | grep "$3" | awk -F "," '{print $3}')
			# echo "ISON=$ISON LEVEL=$LEVEL"
			if [ "$ISON" == "1" ]; then
				LEVEL="0"
			fi
			# Send Command to TOGGLE
			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#SetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceStatusList>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;DeviceStatus&gt;&lt;DeviceID&gt;'$ID'&lt;/DeviceID&gt;&lt;CapabilityID&gt;10008&lt;/CapabilityID&gt;&lt;CapabilityValue&gt;'$LEVEL':0&lt;/CapabilityValue&gt;&lt;IsGroupAction&gt;'$ISGROUP'&lt;/IsGroupAction&gt;&lt;/DeviceStatus&gt;</DeviceStatusList></u:SetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
			UPDATESTATUS=1
		elif [ "$4" == "GETSTATE" ]; then
			UPDATESTATUS=1
			echo "$DEVS" | grep -iE '(/GroupCapabilityValues|/GroupName|/CurrentState|/FriendlyName)' | awk -F "&" '{print $1}' | awk 'NR%2{a=$0;next}{print a","$0;}' | grep "$3" | awk -F "," '{print "ON: "$2"\nLevel: "$3}'
		else
			SHOWUSAGE=1
		fi
	fi
else
	SHOWUSAGE=1
fi

# When you switch LEDs ON/OFF you must request the device status so it will correctly report it later when you use GETSTATE
if [ "$UPDATESTATUS" == "1" ]; then
	if [ "$ISGROUP" == "YES" ]; then
		GRPIDS=$(echo "$DEVS" | grep -iE '(/GroupID)' | awk -F "&" '{print $1}' | awk '{print}' ORS=',' | awk '{print substr($0, 0, length($0)-1)}')
		DEVIDS=$(echo "$DEVS" | grep -iE '(/DeviceID)' | awk -F "&" '{print $1}' | awk '{print}' ORS=',' | awk '{print substr($0, 0, length($0)-1)}')
		# echo "GRPIDS=$GRPIDS ** DEVIDS=$DEVIDS"
		curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#GetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceIDs>'$GRPIDS'</DeviceIDs></u:GetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
		curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#GetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceIDs>'$DEVIDS'</DeviceIDs></u:GetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
	else
		curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:bridge:1#GetDeviceStatus\"" --data '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetDeviceStatus xmlns:u="urn:Belkin:service:bridge:1"><DeviceIDs>'$ID'</DeviceIDs></u:GetDeviceStatus></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/bridge1 > /dev/null
	fi
fi

if [ "$SHOWUSAGE" == "1" ]; then
	echo "COMMAND NOT RECOGNIZED"
	echo ""
	echo "Usage: wemo IP_ADDRESS[:PORT] ON|OFF|TOGGLE|GETSTATE|GETSIGNALSTRENGTH|GETFRIENDLYNAME"
	echo "   or: wemo IP_ADDRESS[:PORT] LINK [LIST|NAME ON [0-255]|OFF|TOGGLE|GETSTATE]"
	exit 255
fi

