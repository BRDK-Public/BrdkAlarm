# BrdkAlarm
Open index.html in help folder for full documentation.

BrdkAlarm is an IEC 61131-3 library that simplifies alarm management on top of B&R's MpAlarmX framework.

## Overview

The library provides the `BrdkAlarmControl` function block, which handles:

- **Runtime alarm configuration** — optionally writes a new alarm config to the MpAlarmX list at startup via `MpComConfigBasic`.
- **Alarm control** — sets and resets alarms through `MpAlarmXSet` / `MpAlarmXResetID` based on a boolean `Condition` input.
- **Delay & inhibit** — supports a configurable delay (`TON`) before triggering and an `Inhibit` input to suppress the alarm.
- **Acknowledge & confirm** — rising-edge detection on `Acknowledge` and `Confirm` inputs to call `MpAlarmXAcknowledgeID` / `MpAlarmXConfirmID`.
- **Error handling** — surfaces errors from `MpComConfigBasic` and provides an `ErrorReset` input to recover.

## Usage

1. Create an instance of `BrdkAlarmControl`.
2. Connect `MpLinkCore` (MpAlarmX Core) and `MpLinkList` (MpAlarmX List) references.
3. Either populate `AlarmConfig` (including its `.Name` field) to configure a new alarm at runtime, **or** set the `Name` input to reference an existing alarm configuration.
4. Set `Enable` to `TRUE`. The FB initialises its internal `MpComConfigBasic`, writes the config if needed, reads it back into the `Info` output, and then enters cyclic alarm monitoring.

### Integration with BrdkPackML

`BrdkAlarmControl` pairs well with `BrdkPackML` to drive PackML reactions (abort, stop, warning) based on alarm severity. Use an array of `BrdkAlarmControl` instances and loop over them to evaluate the appropriate control command:

```iec-st
// Check for alarm reaction
FOR i := 0 TO SIZEOF(BrdkAlarmControl_) / SIZEOF(BrdkAlarmControl_[0]) -1 DO
    IF BrdkAlarmControl_[i].Active THEN
        CASE BrdkAlarmControl_[i].Info.Severity OF
            1: // ABORT
                em.Command.Abort := TRUE;
            2: // STOP
                em.Command.Stop := TRUE;
            3: // WARNING / INFO
                // All others don't trigger a PackML state change
        END_CASE
    END_IF
END_FOR
```

## Dependencies

- `MpAlarmX`
- `MpCom`
- `standard` (TON)

## Version

See [CHANGELOG.md](CHANGELOG.md) for release history.
