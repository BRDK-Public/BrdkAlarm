
FUNCTION_BLOCK BrdkAlarmControl


	IF Enable AND NOT Active THEN
		// Initializing
		
		IF Configuration.NewAlarmConfig.Name <> '' THEN
			internal.alarmCfgName := Configuration.NewAlarmConfig.Name;
			internal.MpComConfigBasic_0.MpLink := Configuration.MpLinkList;
		
			internal.MpComConfigBasic_0.Data := ADR(Configuration.NewAlarmConfig);
			internal.MpComConfigBasic_0.DataType := mpALARMX_CFG_ALARM;
		ELSE
			internal.alarmCfgName := Name;
		END_IF
		
		
		Active := TRUE;
	ELSIF Enable AND Active THEN
		// Cyclic
		CASE state OF
			0:	
				// If there is a new alarm configuration name, then a new alarm is configured at runtime
				// Else we assume it is already configured and ready to control
				IF Configuration.NewAlarmConfig.Name <> '' THEN

					internal.MpComConfigBasic_0.Enable := TRUE;
		
					IF internal.MpComConfigBasic_0.Error THEN
						state := 999;	
					ELSIF internal.MpComConfigBasic_0.Active THEN
						state := 10;
					END_IF
					
				ELSE
					state := 20;
				END_IF

			10:
				// Saving alarm config
				
				internal.MpComConfigBasic_0.CmdWrite := TRUE;
				internal.MpComConfigBasic_0.WriteMode := mpCOM_CONFIG_WRITE_APPEND; 
				
				IF internal.MpComConfigBasic_0.CommandDone THEN
					internal.MpComConfigBasic_0.CmdWrite := FALSE;
					state := 20;
				ELSIF internal.MpComConfigBasic_0.Error THEN
					internal.MpComConfigBasic_0.CmdWrite := FALSE;

					Error := TRUE;
				
					state := 999;
				END_IF
			
			20:
				// Evaluate delay and inhibit			
				IF Delay > 0 THEN
					internal.TON_delay.IN := Condition;
					internal.alarmActive := internal.TON_delay.Q AND NOT Inhibit; 
				ELSE
					internal.TON_delay.IN := FALSE;
					internal.alarmActive := Condition AND NOT Inhibit;
				END_IF
				
				// Monitor alarm state
				IF internal.alarmActive AND internal.instanceID = 0 THEN
					internal.instanceID := MpAlarmXSet(MpLinkCore, internal.alarmCfgName);
				ELSIF NOT internal.alarmActive AND internal.instanceID <> 0 THEN
					MpAlarmXResetID(MpLinkCore, internal.instanceID);
					internal.instanceID := 0;
				END_IF
				
				// Acknowledge the alarm
				IF (Acknowledge AND NOT internal.acknowledgeOld) AND internal.alarmActive AND internal.instanceID <> 0 THEN
					MpAlarmXAcknowledgeID(MpLinkCore, internal.instanceID);
				END_IF
				
				// Confirms the alarm
				IF (Confirm AND NOT internal.confirmOld) AND internal.alarmActive AND internal.instanceID <> 0 THEN
					MpAlarmXConfirmID(MpLinkCore, internal.instanceID);
				END_IF
				
			999:
				// Error state
				internal.MpComConfigBasic_0.ErrorReset := ErrorReset;
				internal.MpComConfigBasic_0.CmdWrite := FALSE;
		
				IF NOT internal.MpComConfigBasic_0.Error THEN
					internal.MpComConfigBasic_0.ErrorReset := FALSE;
				
					state := 0;
				END_IF

		END_CASE
		
		// Set outputs: AlarmActive, InstanceID & StatusID
		AlarmActive := internal.alarmActive AND internal.instanceID <> 0;
		InstanceID := internal.instanceID;
		StatusID := internal.MpComConfigBasic_0.StatusID;
		
		// Function block calls
		internal.MpComConfigBasic_0();
		internal.TON_delay(PT := Delay);
		
	ELSIF NOT Enable AND Active THEN
		// Exiting
		
		// Reset alarm if already active
		IF internal.alarmActive AND internal.instanceID <> 0 THEN
			MpAlarmXResetID(MpLinkCore, internal.instanceID);
		END_IF
		
		// Reset internal variables
		internal.TON_delay.IN := FALSE;
		internal.MpComConfigBasic_0.CmdWrite := FALSE;
		internal.MpComConfigBasic_0.Enable := FALSE;
		internal.instanceID := 0;
		internal.alarmActive := FALSE;
		internal.alarmCfgName := '';
		state := 0;
		
		// Reset outputs
		Active := FALSE;
		AlarmActive := FALSE;
		InstanceID := 0;
		Error := 0;
		StatusID := 0;
		
		// Update old variables
		internal.acknowledgeOld := Acknowledge;
		internal.confirmOld := Confirm;

	END_IF

END_FUNCTION_BLOCK
