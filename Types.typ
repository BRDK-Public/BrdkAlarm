
TYPE
	BrdkAlarmControlInternalType : 	STRUCT 
		MpComConfigBasic_0 : MpComConfigBasic; (*Function block for reading and writing alarm configuration*)
		instanceID : UDINT; (*Unique ID of the alarm when active*)
		TON_delay : TON; (*AlarmDelay timer*)
		alarmActive : BOOL; (*Internal state of the alarm when taking delay and inhibit into account*)
		alarmCfgName : STRING[255]; (*Internal name of the alarm config*)
		acknowledgeOld : BOOL; (*Edge detection*)
		confirmOld : BOOL; (*Edge detection*)
	END_STRUCT;
END_TYPE
