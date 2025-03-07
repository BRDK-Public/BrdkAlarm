
FUNCTION_BLOCK BrdkAlarmControl (*Function block for adding an alarm configuration and controlling the alarm*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the Function Block*)
		MpLinkCore : REFERENCE TO MpComIdentType; (*MpLink of the MpAlarmX Core configuration *)
		Name : STRING[255]; (*Name of an existing alarm configuration*)
		Configuration : BrdkAlarmControlConfigType; (*Used only when a new alarm are to be configured otherwise left empty*)
		Condition : BOOL; (*State of the alarm condition. If TRUE the alarm will be set after the delay if not inhibitted. If FALSE the alarm will be reset*)
		Delay : TIME; (*Alarm Delay. The alarm will be triggered after the delay if the AlarmActive is TRUE and AlarmInhibit is FALSE*)
		Inhibit : BOOL; (*Inhibits the alarm from being set. If already active it will be reset*)
		Acknowledge : BOOL; (*Acknowledge the alarm*)
		Confirm : BOOL; (*Confirming the alarm*)
		ErrorReset : BOOL; (*Resets errors on the MpAlarmXConfigAlarm if it fails to save a new alarm config*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Active when Function Block is enabled*)
		AlarmActive : BOOL; (*True if alarm has been set and False if alarm has been reset*)
		AlarmState : MpAlarmXStateEnum; (*The state of the alarm*)
		InstanceID : UDINT; (*InstanceID of the alarm if Active*)
		StatusID : DINT; (*ID of the status from MpAlarmXConfigAlarm*)
		Error : BOOL; (*An error is active and must be reset*)
	END_VAR
	VAR
		internal : BrdkAlarmControlInternalType; (*Internal type*)
		state : UINT; (*Internal state of the function block*)
	END_VAR
END_FUNCTION_BLOCK
