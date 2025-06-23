# -*- coding: utf-8 -*-
"""
CombiHeatPumpRBC.py

Same as your previous code, but we now return additional RBC variables so that
Dymola can store them in the .mat file. We'll have nDblRea = 13:
  1) T_sp_zone
  2) T_sp_tank
  3) T_amb_w
  4) HEP_w
  5) F1
  6) F2
  7) F3
  8) Fwd_val
  9) flexState (0=FALSE, 1=TRUE)
 10) flexStep (0=None, 1=Step1, 1.5=Step1-both, 2=Step2, 3=Step3, 4=Step4)
 11) LP_global
 12) LP_local
 13) Fwd_mod
"""

import pandas as pd
import numpy as np

##############################################################################
# 1) GLOBAL RBC VARIABLES AND FORECAST STORAGE
##############################################################################

# RBC state dictionary
rbc_state = {
    'flexState': False,
    't_flexExit': 0.0,
    'timeInThisSubsystem': 0.0,
    'eevBelowTime': 0.0,
    'preheatTarget': 'zone',
    'vCounter': 0.0,
    'flexStep': "None"
}

# RBC parameters (same as in rbc_test_controller.py)
N_dwell       = 600     # must remain in the current subsystem at least 10 min
Y_eev_sustain = 300     # EEV <0.9 for 5 min => switch
X_VCOM        = 300     # v_com <0.9 for 5 min
Fwd_mod       = 0.4     # moderate usage threshold
Fwd_high      = 0.8     # high usage threshold

comfort_zone_set   = 295.15  # 22°C occupant baseline
Z_comfort_nominal  = 295.15  # 22°C nominal
Z_comfort_lower    = 293.15  # 20°C
Z_comfort_upper    = 299.15  # 26°C
T_db               = 0.5     # small offset

comfort_tank_set   = 318.15  # 45°C occupant baseline
T_comfort_lower    = 318.15  # 45°C
T_comfort_upper    = 325.15  # 52°C

LP_global = None  # price threshold for high prices
LP_local  = None  # price threshold for local "cheap" prices

# Storage for forecast data
df_forecast       = None
rows_per_hour     = 60    # default (for 1-min data)
zone_horizon_hours = 4
zone_sub_hours    = 2
horizon_rows      = zone_horizon_hours * rows_per_hour
sub_rows          = zone_sub_hours * rows_per_hour

tank_horizon_hours = 5
tank_sub_rows      = tank_horizon_hours * rows_per_hour

##############################################################################
# 2) FORECAST LOADING AND WEIGHTING FUNCTIONS
##############################################################################

def load_forecast_data(csv_path):
    """Load forecast CSV and sort by time ascending."""
    df = pd.read_csv(csv_path)
    return df.sort_values(by='time').reset_index(drop=True)

def compute_weights(N):
    """Compute weighting factors w_k = p/k, with sum(w_k)=1."""
    denom = sum(1.0 / m for m in range(1, N+1))
    p = 1.0 / denom
    return [p / k for k in range(1, N+1)]

def init_rbc_forecast(csv_path, dt_default, horizon_h, sub_h):
    """
    Load forecast data once and compute price thresholds + horizon rows.
    Called during the first doStep invocation if not yet initialized.
    """
    global df_forecast, LP_global, LP_local
    global rows_per_hour, horizon_rows, sub_rows, tank_sub_rows

    # Load data
    df = load_forecast_data(csv_path)
    df_forecast = df

    # Price thresholds
    # Adjust to your liking or read from the RBC arguments
    LP_global = df_forecast[:1440]['HEP'].quantile(0.75)
    LP_local  = df_forecast[:1440]['HEP'].quantile(0.25)

    # If needed, refine dt from forecast data. For simplicity, just use dt_default.
    dt_fore = dt_default

    rows_per_hour = int(round(3600.0 / dt_fore))
    horizon_rows  = horizon_h * rows_per_hour
    sub_rows      = sub_h   * rows_per_hour
    tank_sub_rows = tank_horizon_hours * rows_per_hour

def compute_weighted_amb_hep(i):
    """Weighted T_amb & HEP over next horizon_rows steps from row i."""
    if df_forecast is None or i < 0:
        return 0.0, 0.0
    w = compute_weights(horizon_rows)
    T_ambw, HEPw = 0.0, 0.0
    for k in range(horizon_rows):
        idx = i + k
        if idx < len(df_forecast):
            T_ambw += w[k] * df_forecast.loc[idx, 'T_amb']
            HEPw   += w[k] * df_forecast.loc[idx, 'HEP']
    return T_ambw, HEPw

def compute_F_values(i):
    """Compute partial sums F1, F2, F3 with weighting for sub-horizons."""
    if df_forecast is None or i < 0:
        return 0.0, 0.0, 0.0
    w = compute_weights(sub_rows)
    price_array = df_forecast['HEP'].values
    F1, F2, F3 = 0.0, 0.0, 0.0
    # sub-horizon #1
    for k in range(sub_rows):
        idx = i + k
        if idx < len(price_array):
            F1 += price_array[idx] * w[k]
    # sub-horizon #2
    for k in range(sub_rows):
        idx = i + 60 + k
        if idx < len(price_array):
            F2 += price_array[idx] * w[k]
    # sub-horizon #3
    for k in range(sub_rows):
        idx = i + 120 + k
        if idx < len(price_array):
            F3 += price_array[idx] * w[k]
    return F1, F2, F3

def compute_Fwd(i):
    """Compute weighted water usage forecast for next 5 hours."""
    if df_forecast is None or i < 0:
        return 0.0
    usage_array = df_forecast['usage_predicted'].values
    val = 0.0
    hour_chunk = tank_sub_rows // 5
    # Simple weighting for demonstration
    w1 = w2 = w3 = w4 = w5 = 0.7
    for k in range(tank_sub_rows):
        idx = i + k
        if idx < len(usage_array):
            # pick weight for each hour chunk
            if k < hour_chunk:
                weight = w1
            elif k < 2 * hour_chunk:
                weight = w2
            elif k < 3 * hour_chunk:
                weight = w3
            elif k < 4 * hour_chunk:
                weight = w4
            else:
                weight = w5
            val += usage_array[idx] * weight
    return val

##############################################################################
# 3) ZONE/TANK SETPOINT LOGIC
##############################################################################

def calc_zone_preheat_setpoint(hep_weighted, t_amb_weighted):
    """From the original code: dynamic zone setpoint logic."""
    T_sp = comfort_zone_set
    if hep_weighted <= LP_local:
        if t_amb_weighted <= (5.0 + 273.15):
            T_sp = Z_comfort_upper - T_db
        elif t_amb_weighted <= (10.0 + 273.15):
            T_sp = 0.5 * (Z_comfort_nominal + Z_comfort_upper)
        else:
            T_sp = Z_comfort_nominal + T_db
    else:
        if t_amb_weighted <= (5.0 + 273.15):
            T_sp = 0.5 * (Z_comfort_nominal + Z_comfort_upper)
        else:
            T_sp = Z_comfort_nominal + T_db
    return T_sp

def calc_tank_preheat_setpoint(hep_weighted, usageF, T_bottom, EEV):
    """Currently this function is not used; From the original code: dynamic tank setpoint logic."""
    T_sp = comfort_tank_set
    if (hep_weighted <= LP_local) and (usageF > Fwd_high) and (EEV < 0.8):
        T_sp = T_comfort_upper - T_db
    else:
        T_sp = 0.5 * (T_comfort_lower + T_comfort_upper)
    return T_sp

##############################################################################
# 4) RBC LOGIC: get_rbc_setpoints
##############################################################################

def get_rbc_setpoints(currentTime, v_com, EEV, T_zone, T_tank_lower, T_tank_upper, dt):
    """
    Advanced RBC logic. 
    1) If current price > LP_global => set low setpoints (shedding).
    2) Otherwise, check occupant comfort, track whether we can flex, etc.
    3) Return zone & tank setpoints along with RBC debug info.
    """
    global rbc_state
    global LP_global, LP_local
    global df_forecast

    # If no forecast loaded => occupant baseline
    if (df_forecast is None) or (df_forecast.empty):
        return (comfort_zone_set,
                comfort_tank_set,
                0.0, 0.0, 0.0, 0.0, 0.0,
                0.0,
                rbc_state)
    
    # Find forecast index closest to currentTime
    abs_diff = np.abs(df_forecast['time'] - currentTime)
    i = abs_diff.idxmin()

    # Weighted T_amb, price, usage, etc.
    T_amb_w, HEP_w = compute_weighted_amb_hep(i)
    F1, F2, F3 = compute_F_values(i)
    Fwd_val    = compute_Fwd(i)
    hep_now    = df_forecast.loc[i, 'HEP']

    # If price is high => set zone/tank to lower comfort bounds
    if hep_now > LP_global:
        T_sp_zone = Z_comfort_lower
        T_sp_tank = T_comfort_lower
        rbc_state['flexState'] = False
        rbc_state['flexStep']  = "None"
        print(f"[DEBUG] time={currentTime}s => HIGH PRICE => T_sp_zone={T_sp_zone}, T_sp_tank={T_sp_tank}")
        return (T_sp_zone, T_sp_tank, T_amb_w, HEP_w, F1, F2, F3, Fwd_val, rbc_state)

    # Normal RBC logic
    zone_in_band = (Z_comfort_lower - T_db <= T_zone <= Z_comfort_upper + T_db)
    occupantOK   = zone_in_band

    # Track v_com < 0.9 => increment vCounter
    if v_com < 0.9:
        rbc_state['vCounter'] += dt
    else:
        rbc_state['vCounter'] = 0.0
    vcomOK = (rbc_state['vCounter'] >= X_VCOM)

    # hepOK => immediate check
    hepOK = (hep_now <= LP_global)

    # Track EEV < 0.9 => increment eevBelowTime
    if EEV < 0.9:
        rbc_state['eevBelowTime'] += dt
    else:
        rbc_state['eevBelowTime'] = 0.0
    eevBelowSustain = (rbc_state['eevBelowTime'] >= Y_eev_sustain)

    # Is price about to rise
    hep_increasing = ((F2 > F1) or ((F2 <= F1) and (F3 > F1)))

    flexState     = rbc_state['flexState']
    timeInSub     = rbc_state['timeInThisSubsystem']
    preheatTarget = rbc_state['preheatTarget']

    can_enter_flex = (occupantOK and hepOK and hep_increasing)

    T_sp_zone = comfort_zone_set
    T_sp_tank = comfort_tank_set

    print(f"[DEBUG] time={currentTime}s => occupantComfort={occupantOK}, "
          f"vcomOK={vcomOK}, hepOK={hepOK}, hep_increasing={hep_increasing}, "
          f"flexState={flexState}")

    # Flex transitions
    if not flexState:
        # NON-FLEX
        if can_enter_flex:
            flexState = True
            timeInSub = 0.0
            rbc_state['eevBelowTime'] = 0.0
            # 4-step chain
            if Fwd_val > Fwd_mod:
                if (T_tank_lower > T_zone + T_db) and vcomOK:
                    preheatTarget = 'both'
                    rbc_state['flexStep'] = "Step1-both"
                else:
                    preheatTarget = 'tank'
                    rbc_state['flexStep'] = "Step1"
            elif (T_tank_lower > T_zone + T_db) and vcomOK:
                preheatTarget = 'zone'
                rbc_state['flexStep'] = "Step2"
            else:
                if eevBelowSustain:
                    preheatTarget = 'tank'
                    rbc_state['flexStep'] = "Step3"
                else:
                    preheatTarget = 'zone'
                    rbc_state['flexStep'] = "Step4"
        # else remain occupant baseline
    else:
        # Already in FLEX
        if not can_enter_flex:
            # Exit flex
            flexState = False
            rbc_state['flexStep'] = "None"
        else:
            # Remain flex => possibly toggle sub-target
            timeInSub += dt
            if timeInSub >= N_dwell:
                timeInSub = 0.0
                rbc_state['eevBelowTime'] = 0.0
                # 4-step chain again
                if Fwd_val > Fwd_mod:
                    if (T_tank_lower > (T_zone + T_db)) and vcomOK:
                        preheatTarget = 'both'
                        rbc_state['flexStep'] = "Step1-both"
                    else:
                        preheatTarget = 'tank'
                        rbc_state['flexStep'] = "Step1"
                elif (T_tank_lower > (T_zone + T_db)) and vcomOK:
                    preheatTarget = 'zone'
                    rbc_state['flexStep'] = "Step2"
                else:
                    if eevBelowSustain:
                        preheatTarget = 'tank'
                        rbc_state['flexStep'] = "Step3"
                    else:
                        preheatTarget = 'zone'
                        rbc_state['flexStep'] = "Step4"

    # Compute setpoints if in FLEX
    if flexState:
        if preheatTarget == 'tank':
            T_sp_tank = T_comfort_upper - T_db
            T_sp_zone = comfort_zone_set
        elif preheatTarget == 'zone':
            T_sp_zone = calc_zone_preheat_setpoint(HEP_w, T_amb_w)
            T_sp_tank = comfort_tank_set
        elif preheatTarget == 'both':
            T_sp_tank = T_comfort_upper - T_db
            T_sp_zone = calc_zone_preheat_setpoint(HEP_w, T_amb_w)

    # Update RBC state
    rbc_state['flexState']           = flexState
    rbc_state['timeInThisSubsystem'] = timeInSub
    rbc_state['preheatTarget']       = preheatTarget

    return (T_sp_zone, T_sp_tank, T_amb_w, HEP_w, F1, F2, F3, Fwd_val, rbc_state)


##############################################################################
# 5) THE doStep(...) FUNCTION FOR DYMOLA
##############################################################################

def doStep(dblInp, state):
    """
    The single entry point that Dymola will call at every time step.
    
    dblInp: A list of floats, e.g.:
        dblInp[0] = currentTime (in seconds)
        dblInp[1] = T_zone
        dblInp[2] = T_tank_lower
        dblInp[3] = T_tank_upper
        dblInp[4] = v_com
        dblInp[5] = EEV

    state:  A persistent Python object to store memory across calls.
            If None, we initialize everything (forecast load, RBC state, etc.).

    Returns:
      [ [T_sp_zone, T_sp_tank], updatedState ]
	  
    We now return 13 real outputs:
      1) T_sp_zone
      2) T_sp_tank
      3) T_amb_w
      4) HEP_w
      5) F1
      6) F2
      7) F3
      8) Fwd_val
      9) flexState (0 or 1)
     10) flexStep (encoded as 0..4 or 1.5)
     11) LP_global
     12) LP_local
     13) Fwd_mod
    Make sure you set nDblRea=13 in your Modelica block.
    """
    global rbc_state, df_forecast
    global LP_global, LP_local, Fwd_mod

    # ----------------------------------------------------------------------
    # 1) Initialization
    # ----------------------------------------------------------------------
    if state is None:
        state = {}
        # The first time we call doStep, load forecast data and set RBC thresholds
        init_rbc_forecast(
            csv_path="dynamic_price_generated_waterdraw_imperfect.csv",  # or your actual file
            dt_default=60,       # assume forecast data has 1-min step
            horizon_h=4,
            sub_h=2
        )
        # Reset RBC state to default
        rbc_state = {
            'flexState': False,
            't_flexExit': 0.0,
            'timeInThisSubsystem': 0.0,
            'eevBelowTime': 0.0,
            'preheatTarget': 'zone',
            'vCounter': 0.0,
            'flexStep': "None"
        }
        # Store time for dt
        state['timeLast'] = dblInp[0]

    # ----------------------------------------------------------------------
    # 2) Unpack inputs
    # ----------------------------------------------------------------------
    currentTime   = float(dblInp[0])
    T_zone        = float(dblInp[1])
    T_tank_lower  = float(dblInp[2])
    T_tank_upper  = float(dblInp[3])
    v_com         = float(dblInp[4])
    EEV           = float(dblInp[5])

    # ----------------------------------------------------------------------
    # 3) Compute dt = 900
    # ----------------------------------------------------------------------
    # The user states dt=900 is not co-sim, it's a fixed step.
    dt = 900.0
    state['timeLast'] = currentTime

    # ----------------------------------------------------------------------
    # 4) Call the RBC logic function
    # ----------------------------------------------------------------------
    (T_sp_zone,
     T_sp_tank,
     T_amb_w,
     HEP_w,
     F1, F2, F3,
     Fwd_val,
     updated_rbc_state) = get_rbc_setpoints(
        currentTime   = currentTime,
        v_com         = v_com,
        EEV           = EEV,
        T_zone        = T_zone,
        T_tank_lower  = T_tank_lower,
        T_tank_upper  = T_tank_upper,
        dt            = dt
    )

    rbc_state.update(updated_rbc_state)

    # Convert flexState (bool) => real
    if rbc_state['flexState']:
        flexStateReal = 1.0
    else:
        flexStateReal = 0.0

    # Convert flexStep (string) => real code
    stepMapping = {
        "None":      0.0,
        "Step1":     1.0,
        "Step1-both":1.5,
        "Step2":     2.0,
        "Step3":     3.0,
        "Step4":     4.0
    }
    stepString = rbc_state['flexStep']
    flexStepReal = stepMapping.get(stepString, 0.0)  # default=0.0 if key not found

    # 5) Build output array
    # We'll have 13 items in total:
    outputs = [
        T_sp_zone,     # (1)
        T_sp_tank,     # (2)
        T_amb_w,       # (3)
        HEP_w,         # (4)
        F1,            # (5)
        F2,            # (6)
        F3,            # (7)
        Fwd_val,       # (8)
        flexStateReal, # (9)
        flexStepReal,  # (10)
        (LP_global if LP_global else 0.0), # (11) fallback=0 if None
        (LP_local  if LP_local  else 0.0), # (12)
        Fwd_mod        # (13)
    ]

    return [outputs, state]
