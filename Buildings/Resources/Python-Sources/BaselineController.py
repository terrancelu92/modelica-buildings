# -*- coding: utf-8 -*-

def doStep(dblInp, state):
    """
    The Buildings interface function.

    Inputs (dblInp):
      - We assume nDblWri=6 if you pass:
          dblInp[0] = currentTime (s)
          dblInp[1] = T_zone
          dblInp[2] = T_tank_lower
          dblInp[3] = T_tank_upper
          dblInp[4] = v_com
          dblInp[5] = EEV
      - If some of these are unused, that's fine.

    state:
      - A persistent Python object for retaining data across calls.
      - If state is None, it's the first call.

    Outputs:
      - We return only 2 real values in the "outputs" array, i.e. nDblRea=2.
        outputs[0] = T_sp_zone (constant 295.15)
        outputs[1] = T_sp_tank (constant 318.15)

    Usage in Modelica:
      - Set passPythonObject=true
      - Set nDblWri=6 (or however many real inputs you pass)
      - Set nDblRea=2
      - functionName="BaselineController.doStep"
    """

    # If this is the first call, initialize the state if needed
    if state is None:
        state = {}
        state['timeLast'] = dblInp[0]
        # (You could store or log anything else here if desired.)

    # Unpack inputs, though we don't use them for this baseline
    currentTime   = float(dblInp[0])
    T_zone        = float(dblInp[1])
    T_tank_lower  = float(dblInp[2])
    T_tank_upper  = float(dblInp[3])
    v_com         = float(dblInp[4])
    EEV           = float(dblInp[5])

    # We won't compute anything dynamic. Just return constant setpoints.
    T_sp_zone = 273.15 + 22.0  # 22°C
    T_sp_tank = 273.15 + 45.0  # 45°C

    # Build outputs
    outputs = [T_sp_zone, T_sp_tank]

    # Return [outputs, updatedState]
    return [outputs, state]
