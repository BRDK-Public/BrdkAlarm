
FUNCTION_BLOCK BrdkAlarmControl
	
	IF Enable AND NOT Active THEN
		// Initializing
		Active := TRUE;
		
	ELSIF Enable AND Active THEN
		// Cyclic
		CASE state OF
			0:
				// Initialize MpComConfigBasic for interaction with alarm configuration
				Error := FALSE;
				
				internal.MpComConfigBasic_0.Enable := TRUE;
				internal.MpComConfigBasic_0.MpLink := ADR(MpLinkList);
				internal.MpComConfigBasic_0.DataType := mpALARMX_CFG_ALARM;
				
				IF internal.MpComConfigBasic_0.Error THEN
					StatusID := internal.MpComConfigBasic_0.StatusID;
					state := 999;
				ELSIF internal.MpComConfigBasic_0.Active THEN
					state := 10;
				END_IF
				
			10:
				// If there is a new alarm configuration name, then a new alarm is configured at runtime
				// Else we assume it is already configured and ready to control
				
				IF AlarmConfig.Name <> '' THEN
					internal.alarmCfgName := AlarmConfig.Name;
					IF Name <> '' THEN
						internal.alarmInstanceName := Name;
					ELSE
						internal.alarmInstanceName := AlarmConfig.Name;
					END_IF
					state := 20;
				ELSE
					IF Name <> '' THEN
						internal.alarmInstanceName := Name;
						IF NameInConfig <> '' THEN
							internal.alarmCfgName := NameInConfig;
						ELSE
							internal.alarmCfgName := Name;
						END_IF
						state := 30;
					ELSE
						StatusID := mpALARMX_ERR_NAME_NULL;
						state := 999;
					END_IF
				END_IF

			20:
				// Saving alarm config
				internal.MpComConfigBasic_0.CmdWrite := TRUE;
				internal.MpComConfigBasic_0.WriteMode := mpCOM_CONFIG_WRITE_APPEND; 
				internal.MpComConfigBasic_0.Data := ADR(AlarmConfig);
				
				IF internal.MpComConfigBasic_0.CommandDone THEN
					internal.MpComConfigBasic_0.CmdWrite := FALSE;
					state := 30;
				ELSIF internal.MpComConfigBasic_0.Error THEN
					internal.MpComConfigBasic_0.CmdWrite := FALSE;
					StatusID := internal.MpComConfigBasic_0.StatusID;
					state := 999;
				END_IF
				
			30:
				// Reading the actual alarm config for the Info output
				internal.MpComConfigBasic_0.CmdRead := TRUE;
				internal.MpComConfigBasic_0.Path := ADR(internal.alarmCfgName);
				internal.MpComConfigBasic_0.Data := ADR(Info);
				
				IF internal.MpComConfigBasic_0.CommandDone THEN
					internal.MpComConfigBasic_0.CmdRead := FALSE;
					internal.MpComConfigBasic_0.Enable := FALSE;
					state := 100;
				ELSIF internal.MpComConfigBasic_0.Error THEN
					internal.MpComConfigBasic_0.CmdRead := FALSE;
					StatusID := internal.MpComConfigBasic_0.StatusID;
					state := 999;
				END_IF
			
			100:
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
					internal.instanceID := MpAlarmXSet(MpLinkCore, internal.alarmInstanceName);
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
				Error := TRUE;

				IF internal.MpComConfigBasic_0.Error THEN
					internal.MpComConfigBasic_0.Enable := TRUE;
					internal.MpComConfigBasic_0.MpLink := ADR(MpLinkList);
					internal.MpComConfigBasic_0.ErrorReset := ErrorReset;
					internal.MpComConfigBasic_0.CmdWrite := FALSE;
					internal.MpComConfigBasic_0.CmdRead := FALSE;
				END_IF
				
				IF ErrorReset AND NOT internal.errorResetOld THEN
					IF NOT internal.MpComConfigBasic_0.Error THEN
						internal.MpComConfigBasic_0.ErrorReset := FALSE;
						internal.MpComConfigBasic_0.Enable := FALSE;
						StatusID := 0;
						state := 0;
					END_IF
				END_IF
		END_CASE
		
		// Set outputs
		AlarmActive := internal.alarmActive AND internal.instanceID <> 0;
		InstanceID := internal.instanceID;
		
	ELSIF NOT Enable AND Active THEN
		// Exiting
		
		// Reset alarm if already active
		IF internal.alarmActive AND internal.instanceID <> 0 THEN
			MpAlarmXResetID(MpLinkCore, internal.instanceID);
		END_IF
		
		// Reset internal variables
		internal.TON_delay.IN := FALSE;
		internal.MpComConfigBasic_0.CmdWrite := FALSE;
		internal.MpComConfigBasic_0.CmdRead := FALSE;
		internal.MpComConfigBasic_0.Enable := FALSE;
		internal.instanceID := 0;
		internal.alarmActive := FALSE;
		internal.alarmInstanceName := '';
		internal.alarmCfgName := '';
		state := 0;
		
		// Reset outputs
		Active := FALSE;
		Error := FALSE;
		AlarmActive := FALSE;
		InstanceID := 0;
		Error := 0;
		StatusID := 0;

	END_IF

	// Update old variables
	internal.acknowledgeOld := Acknowledge;
	internal.confirmOld := Confirm;
	internal.errorResetOld := ErrorReset;

	// Function block calls
	internal.MpComConfigBasic_0();
	internal.TON_delay(PT := Delay);

END_FUNCTION_BLOCK
