
FUNCTION_BLOCK BrdkAlarmControl (*Function block for adding an alarm configuration and controlling the alarm*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the Function Block*)
		MpLinkCore : REFERENCE TO MpComIdentType; (*MpLink of the MpAlarmX Core configuration *)
		MpLinkList : REFERENCE TO MpComIdentType; (*MpLink of the MpAlarmX Core configuration *)
		AlarmConfig : MpAlarmXCfgListAlarmType := (Code:=0,Severity:=1,Behavior:=(Type:=mpALARMX_CFG_LIST_PERSISTENT,Edge:=(Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,MultipleInstances:=TRUE,ReactionWhilePending:=TRUE,Retain:=FALSE,Asynchronous:=FALSE,DataUpdate:=(Activation:=(Timestamp:=FALSE,Snippets:=FALSE)),HistoryReport:=(InactiveToActive:=TRUE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE)),Persistent:=(Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,MultipleInstances:=FALSE,ReactionWhilePending:=TRUE,Retain:=FALSE,Asynchronous:=FALSE,DataUpdate:=(Activation:=(Timestamp:=FALSE,Snippets:=FALSE)),HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=FALSE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE)),UserDefined:=(AutoReset:=FALSE,Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,MultipleInstances:=FALSE,ReactionWhilePending:=TRUE,Retain:=FALSE,Asynchronous:=FALSE,DataUpdate:=(Activation:=(Timestamp:=FALSE,Snippets:=FALSE)),HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=TRUE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE)),Level:=(Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,ReactionWhilePending:=TRUE,HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=FALSE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE),Monitoring:=(Exclusive:=TRUE,LowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),LowLowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighHighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),Settings:=(Type:=mpALARMX_CFG_LIST_STATIC,Static:=(Delay:=0,Hysteresis:=0)))),Deviation:=(Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,ReactionWhilePending:=TRUE,HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=FALSE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE),Monitoring:=(Exclusive:=TRUE,LowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),LowLowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighHighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),Settings:=(Type:=mpALARMX_CFG_LIST_STATIC,Static:=(Delay:=0,Hysteresis:=0)))),RateOfChange:=(Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,ReactionWhilePending:=TRUE,HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=FALSE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE),Monitoring:=(Exclusive:=TRUE,LowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),LowLowLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),HighHighLimit:=(Type:=mpALARMX_CFG_LIST_LIMIT_DISABLED,LimitStatic:=(Limit:=0)),Settings:=(Type:=mpALARMX_CFG_LIST_TIM_STATIC,Static:=(Delay:=0,TimeConstant:=0)))),Discrete:=(Acknowledge:=mpALARMX_CFG_LIST_ACK_REQ,Confirm:=mpALARMX_CFG_LIST_CFM_DISABLED,ReactionWhilePending:=TRUE,HistoryReport:=(InactiveToActive:=TRUE,ActiveToInactive:=FALSE,UnacknowledgedToAcknowledged:=TRUE,AcknowledgedToUnacknowledged:=FALSE,UnconfirmedToConfirmed:=TRUE,ConfirmedToUnconfirmed:=FALSE,Update:=FALSE),Monitoring:=(Trigger:=(NumberOfAlarmValues:=0)))),Disable:=FALSE); (*Configuration of a new alarm to the list*)
		Name : STRING[255]; (*Name of an existing alarm configuration*)
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
		Info : MpAlarmXCfgListAlarmType; (*Alarm config info*)
		Error : BOOL; (*An error is active and must be reset*)
	END_VAR
	VAR
		internal : BrdkAlarmControlInternalType; (*Internal type*)
		state : UINT; (*Internal state of the function block*)
	END_VAR
END_FUNCTION_BLOCK
