# -*- coding: utf-8 -*-
"""
Minimal-Change RBC Script
-------------------------
This script is based on your original open_loop_rbc_test_v1.py, but:
  1) Removes the need for 'measurement_csv'.
  2) Keeps all debug prints & RBC logic intact.
  3) Introduces a function 'init_rbc_forecast(...)' to load/prepare forecast data.
  4) Introduces a function 'get_rbc_setpoints(...)' that takes the current
     measured states from your FMU and returns RBC setpoints plus updated RBC state.
  
You can import this script into your run_fmu_pyfmi code (or any driver script).
"""

import pandas as pd
import numpy as np

##############################################################################
# RBC STATE & GLOBAL PARAMETERS
##############################################################################

# Dictionary to store RBC states (e.g., whether we are in flex mode).
rbc_state = {
    'flexState': False,       # True if in Flex mode, False if not
    't_flexExit': 0.0,        # last 'time' (in seconds) we exited flex
    'timeInThisSubsystem': 0.0,
    'eevBelowTime': 0.0,      # how many seconds EEV has been < 0.9
    'preheatTarget': 'zone',
    'vCounter': 0.0,           # how many seconds v_com < 0.9
    'flexStep': "None"        # "Step1", "Step2", "Step3", "Step4", or "None"    
}

# Global RBC parameters (same names as original)
chunk_size      = 15     # RBC update every chunk_size rows
N_dwell         = 600   # must remain on the current subsystem at least 10 min
Y_eev_sustain   = 300   # require 5 minutes with EEV<0.9 to avoid toggling
X_VCOM          = 300   # v_com < 0.9 for 300s => 5 min
Fwd_mod         = 0.4  # moderate hot water usage threshold
Fwd_high        = 0.8  # high hot water usage threshold
#Fwd_mod         = 0.10  # moderate hot water usage threshold
#Fwd_high        = 0.18  # high hot water usage threshold
#Fwd_mod         = 0.12  # moderate hot water usage threshold
#Fwd_high        = 0.20  # high hot water usage threshold

# Occupant comfort zone nominal setpoint (non-flex baseline)
comfort_zone_set   = 295.15  # e.g., 22°C occupant baseline
Z_comfort_nominal  = 295.15  # 22°C

# Occupant comfort zone bounds
Z_comfort_lower  = 293.15  # 20°C
Z_comfort_upper  = 299.15  # 26°C
T_db             = 0.5     # small offset used as "ech" if needed

# Occupant comfort tank nominal setpoint (non-flex baseline)
comfort_tank_set = 318.15  # e.g., 45°C occupant baseline

# Occupant comfort tank bounds
T_comfort_lower  = 318.15  # 45°C
T_comfort_upper  = 325.15  # 52°C

# Global price thresholds (to be computed after loading forecast)
LP_global = None
LP_local = None

# Storage for forecast & weighting
df_forecast = None
rows_per_hour = 60    # default (if forecast has 1-min steps)

# For zone: use a 4-hour prediction horizon with a 2-hour sub-horizon (sliding windows: 0-2, 1-3, 2-4 hours)
zone_horizon_hours = 4
zone_sub_hours = 2
horizon_rows  = zone_horizon_hours * rows_per_hour   # e.g., 240
sub_rows      = zone_sub_hours * rows_per_hour         # e.g., 120

# For tank: use a 5-hour prediction horizon for the water usage forecast.
tank_horizon_hours = 5
# Define a new variable for the tank’s prediction horizon (in rows)
tank_sub_rows = tank_horizon_hours * rows_per_hour     # e.g., 300

##############################################################################
# HELPER FUNCTIONS FOR LOADING & PROCESSING FORECAST
##############################################################################

def load_csv_data(csv_path):
    """
    Load and sort a CSV by 'time' ascending.
    """
    df = pd.read_csv(csv_path)
    df = df.sort_values(by='time').reset_index(drop=True)
    return df

def compute_weights(N):
    """
    Weighted factors W_k = p/k, sum_{k=1..N}(W_k)=1 => p=1 / sum_{m=1..N}(1/m).
    Returns an array [W1,...,WN].
    """
    denom = sum(1.0/m for m in range(1, N+1))
    p = 1.0 / denom
    return [p/k for k in range(1, N+1)]

def init_rbc_forecast(forecast_csv, dt_default, horizon_hours, sub_hours):
    """
    Load the forecast CSV (time, HEP, usage, T_amb),
    compute global price thresholds (LP_global, LP_local),
    and set up horizon_rows/sub_rows based on dt_default if needed.
    """
    global df_forecast, LP_global, LP_local
    global rows_per_hour, horizon_rows, sub_rows, tank_sub_rows

    # 1) Load forecast data
    df_forecast = load_csv_data(forecast_csv)

    # 2) Determine dt from first two rows
    dt_fore = dt_default
    #if len(df_forecast) > 1:
        #possible_dt = df_forecast.loc[1, 'time'] - df_forecast.loc[0, 'time']
        #if possible_dt > 0:
            #dt_fore = possible_dt

    # 3) Price thresholds
    LP_global = df_forecast['HEP'].quantile(0.75)
    #LP_local  = df_forecast['HEP'].quantile(0.25)
    #LP_global = df_forecast['HEP'].quantile(0.75) + 0.14 # add a marginal value to accomodate TOU rate
    LP_local  = df_forecast['HEP'].quantile(0.25) + 0.1 # add a marginal value to accomodate TOU rate

    # 4) Compute horizon_rows & sub_rows
    rows_per_hour = int(round(3600.0 / dt_fore))
    horizon_rows  = horizon_hours * rows_per_hour
    sub_rows      = sub_hours * rows_per_hour
    tank_sub_rows = tank_horizon_hours * rows_per_hour

    print("[INFO] RBC forecast initialized.")
    print(f"[INFO] dt_fore={dt_fore:.1f}s, horizon_hours={horizon_hours}, sub_hours={sub_hours}")
    print(f"[INFO] tank_horizon_hours={tank_horizon_hours}")
    print(f"[INFO] LP_global={LP_global:.3f}, LP_local={LP_local:.3f}")

def compute_weighted_amb_hep(i):
    """
    Weighted T_amb & HEP for the next horizon_rows steps from row i in df_forecast.
    """
    if df_forecast is None or i<0:
        return 0.0, 0.0
    w = compute_weights(horizon_rows)
    T_ambw, HEPw = 0.0, 0.0
    for k in range(1, horizon_rows + 1):
        idx = i + k - 1
        if idx < len(df_forecast):
            T_ambw += w[k - 1] * df_forecast.loc[idx, 'T_amb']
            HEPw   += w[k - 1] * df_forecast.loc[idx, 'HEP']
    return T_ambw, HEPw

def compute_F_values(i):
    """
    Sub-horizon partial sums for F1, F2, F3 with weighting.
    """
    if df_forecast is None or i<0:
        return 0.0, 0.0, 0.0

    w = compute_weights(sub_rows)
    price_array = df_forecast['HEP'].values

    F1, F2, F3 = 0.0, 0.0, 0.0
    for k in range(1, sub_rows + 1):
        idx = i + k
        if idx < len(price_array):
            F1 += price_array[idx] * w[k - 1]
    for k in range(1, sub_rows + 1):
        idx = i + 60 + k    # hard coded-> interval between the moving windows
        if idx < len(price_array):
            F2 += price_array[idx] * w[k - 1]
    for k in range(1, sub_rows + 1):
        idx = i + 2*60 + k
        if idx < len(price_array):
            F3 += price_array[idx] * w[k - 1]
    return F1, F2, F3

def compute_Fwd(i):
    """
    Weighted water usage forecast for next 3 hours.
    """
    if df_forecast is None or i<0:
        return 0.0
    usage_array = df_forecast['usage_predicted'].values
    val = 0.0
    # If tank_sub_rows covers 5 hours => each chunk = tank_sub_rows//5
    hour_chunk = tank_sub_rows // 5
    w1, w2, w3, w4, w5 = 0.7, 0.7, 0.7, 0.7, 0.7  # You can change these if desired.
    for k in range(1, tank_sub_rows + 1):
        idx = i + k
        if idx < len(usage_array):
            if k <= hour_chunk:
                weight = w1
            elif k <= 2 * hour_chunk:
                weight = w2
            elif k <= 3 * hour_chunk:
                weight = w3
            elif k <= 4 * hour_chunk:
                weight = w4
            else:
                weight = w5
            val += usage_array[idx] * weight
    return val

##############################################################################
# 3-VALUE SETPOINT LOGIC FOR ZONE & TANK
##############################################################################

def calc_zone_preheat_setpoint(hep_weighted, t_amb_weighted):
    """
    Exactly the same logic from the original code.
    """
    T_sp = comfort_zone_set
    if hep_weighted <= LP_local:
        if t_amb_weighted <= 5.0 + 273.15:
            T_sp = Z_comfort_upper - T_db
        elif t_amb_weighted <= 10.0 + 273.15:
            T_sp = 0.5*(Z_comfort_nominal + Z_comfort_upper)
        else:
            T_sp = Z_comfort_nominal + T_db
    else:
        if t_amb_weighted <= 5.0 + 273.15:
            T_sp = 0.5*(Z_comfort_nominal + Z_comfort_upper)
        else:
            T_sp = Z_comfort_nominal + T_db
    return T_sp

def calc_tank_preheat_setpoint(hep_weighted, usageF, T_bottom, EEV):
    """
    Exactly the same logic from the original code.
    """
    T_sp = comfort_tank_set
    if hep_weighted <= LP_local and (usageF > Fwd_high) and (EEV < 0.8):
        T_sp = T_comfort_upper - T_db
    #elif hep_weighted <= LP_local and (Fwd_mod <= usageF <= Fwd_high) and (EEV < 0.9):
        #T_sp = 0.5 * (T_comfort_lower + T_comfort_upper)
    else:
        #T_sp = T_comfort_lower + T_db
        T_sp = 0.5 * (T_comfort_lower + T_comfort_upper)

    return T_sp

##############################################################################
# RBC LOGIC STEP
##############################################################################

def get_rbc_setpoints(
    currentTime,
    v_com,
    EEV,
    T_zone,
    T_tank_lower,
    T_tank_upper,
    dt
):
    """
    Updated RBC logic with a top-layer check:
      1) If hep_now > LP_global => set T_sp_zone=Z_comfort_lower and T_sp_tank=T_comfort_lower.
      2) Otherwise, proceed with the original RBC 'can_enter_flex' checks, etc.
    """

    global rbc_state
    global N_dwell, Y_eev_sustain, X_VCOM
    global comfort_zone_set, comfort_tank_set
    global Z_comfort_lower, Z_comfort_upper, T_db
    global T_comfort_lower, T_comfort_upper
    global Fwd_mod, Fwd_high
    global LP_global, LP_local
    global df_forecast

    # -----------------------------------------------------------------------
    # 1) Identify nearest row in df_forecast by currentTime
    # -----------------------------------------------------------------------
    if df_forecast is None or df_forecast.empty:
        # Fallback: occupant baseline if no forecast
        return (
            comfort_zone_set,
            comfort_tank_set,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            rbc_state
        )

    # Find index i in forecast closest to currentTime
    abs_diff = np.abs(df_forecast['time'] - currentTime)
    i = abs_diff.idxmin()  # row index

    # For later calculations
    T_amb_w, HEP_w = compute_weighted_amb_hep(i)
    F1, F2, F3     = compute_F_values(i)
    Fwd_val        = compute_Fwd(i)
    hep_now        = df_forecast.loc[i, 'HEP']

    # -----------------------------------------------------------------------
    # 2) TOP‐LAYER CHECK => If hep_now > LP_global => set low setpoints
    # -----------------------------------------------------------------------
    if hep_now > LP_global:
        # Price is high => set zone/tank to lower comfort bounds
        T_sp_zone = Z_comfort_lower
        T_sp_tank = T_comfort_lower

        # Optionally, force RBC state out of flex
        rbc_state['flexState'] = False
        rbc_state['flexStep']  = "None"

        print(f"[DEBUG] time={currentTime}s => HIGH PRICE => T_sp_zone={T_sp_zone}, T_sp_tank={T_sp_tank}")

        return (
            T_sp_zone,
            T_sp_tank,
            T_amb_w,  # Weighted T_amb
            HEP_w,    # Weighted HEP
            F1, F2, F3,
            Fwd_val,
            rbc_state
        )

    # -----------------------------------------------------------------------
    # 3) Otherwise, continue with the original RBC logic
    # -----------------------------------------------------------------------

    # Occupant comfort checks (zone only, as before)
    zone_in_band = (Z_comfort_lower - T_db <= T_zone <= Z_comfort_upper + T_db)
    occupantComfortOK = zone_in_band

    # Track v_com < 0.9 => increment rbc_state['vCounter']
    if v_com < 0.9:
        rbc_state['vCounter'] += dt
    else:
        rbc_state['vCounter'] = 0.0
    vcomOK = (rbc_state['vCounter'] >= X_VCOM)

    # hepOK => immediate check => forecast HEP <= LP_global
    hepOK = (hep_now <= LP_global)

    # Track EEV < 0.9 => increment rbc_state['eevBelowTime']
    if EEV < 0.9:
        rbc_state['eevBelowTime'] += dt
    else:
        rbc_state['eevBelowTime'] = 0.0
    eevBelowSustain = (rbc_state['eevBelowTime'] >= Y_eev_sustain)

    # Is price about to rise => (F2>F1) or (F2<=F1 & F3>F1)
    hep_increasing = ((F2 > F1) or ((F2 <= F1) and (F3 > F1)))

    # RBC state references
    flexState     = rbc_state['flexState']
    timeInSub     = rbc_state['timeInThisSubsystem']
    preheatTarget = rbc_state['preheatTarget']

    # Condition for entering flex
    can_enter_flex = (occupantComfortOK and hepOK and hep_increasing)

    # By default => occupant baseline
    T_sp_zone = comfort_zone_set
    T_sp_tank = comfort_tank_set

    # [DEBUG] prints
    print(f"[DEBUG] time={currentTime}s => occupantComfort={occupantComfortOK}, "
          f"vcomOK={vcomOK}, hepOK={hepOK}, hep_increasing={hep_increasing}, "
          f"flexState={flexState}")

    # -----------------------------------------------------------------------
    # 4) Original RBC logic for flex / non-flex transitions
    # -----------------------------------------------------------------------
    if not flexState:
        # NON-FLEX
        if can_enter_flex:
            # Enter flex
            flexState = True
            timeInSub = 0.0
            rbc_state['eevBelowTime'] = 0.0

            # 4-step chain
            if Fwd_val > Fwd_mod:
                if (T_tank_lower > T_zone + T_db) and vcomOK:
                    preheatTarget = 'both'
                    rbc_state['flexStep'] = "Step1-both"
                    print("[DEBUG] Entering FLEX => step(1) => TANK & ZONE => usage>Fwd_mod & T_tank_lower > T_zone + T_db & vcomOK.")
                else:
                    preheatTarget = "tank"
                    rbc_state['flexStep'] = "Step1"
                    print("[DEBUG] Entering FLEX => step(1) => TANK => usage>Fwd_mod.")
            elif (T_tank_lower > T_zone + T_db) and vcomOK:
                preheatTarget = 'zone'
                rbc_state['flexStep'] = "Step2"
                print("[DEBUG] Entering FLEX => step(2) => ZONE => T_tank_lower> T_zone+T_db & vcom<0.9.")
            else:
                if eevBelowSustain:
                    preheatTarget = 'tank'
                    rbc_state['flexStep'] = "Step3"
                    print("[DEBUG] Entering FLEX => step(3) => TANK => EEV<0.9 for Y.")
                else:
                    preheatTarget = 'zone'
                    rbc_state['flexStep'] = "Step4"
                    print("[DEBUG] Entering FLEX => step(4) => ZONE => EEV>=0.9 for Y.")
        else:
            print("[DEBUG] Remain NON-FLEX => occupant baseline.")
    else:
        # Already in FLEX
        if not can_enter_flex:
            # Exit flex
            flexState = False
            rbc_state['flexStep'] = "None"
            print("[DEBUG] Exiting FLEX => occupant comfort or price fails.")
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
                        print("[DEBUG] Flex chain => step(1) => TANK & ZONE => usage>Fwd_mod & T_tank_lower > (T_zone + T_db) & vcom<0.9.")
                    else:
                        preheatTarget = "tank"
                        rbc_state['flexStep'] = "Step1"
                        print("[DEBUG] Flex chain => step(1) => TANK => usage>Fwd_mod.")
                elif (T_tank_lower > (T_zone + T_db)) and vcomOK:
                    preheatTarget = 'zone'
                    rbc_state['flexStep'] = "Step2"
                    print("[DEBUG] Flex chain => step(2) => ZONE => T_tank_lower > T_zone+T_db & vcom<0.9.")
                else:
                    if eevBelowSustain:
                        preheatTarget = 'tank'
                        rbc_state['flexStep'] = "Step3"
                        print("[DEBUG] Flex chain => step(3) => TANK => EEV<0.9 for Y.")
                    else:
                        preheatTarget = 'zone'
                        rbc_state['flexStep'] = "Step4"
                        print("[DEBUG] Flex chain => step(4) => ZONE => EEV>=0.9 for Y.")

    # -----------------------------------------------------------------------
    # 5) Compute final setpoints if in FLEX
    # -----------------------------------------------------------------------
    if flexState:
        if preheatTarget == 'tank':
            #T_sp_tank = calc_tank_preheat_setpoint(HEP_w, Fwd_val, T_tank_lower, EEV)
            T_sp_tank = T_comfort_upper - T_db
            T_sp_zone = comfort_zone_set
        elif preheatTarget == 'zone':
            T_sp_zone = calc_zone_preheat_setpoint(HEP_w, T_amb_w)
            T_sp_tank = comfort_tank_set
        elif preheatTarget == 'both':
            #T_sp_tank = calc_tank_preheat_setpoint(HEP_w, Fwd_val, T_tank_lower, EEV)
            T_sp_tank = T_comfort_upper - T_db
            T_sp_zone = calc_zone_preheat_setpoint(HEP_w, T_amb_w)
    else:
        T_sp_zone = comfort_zone_set
        T_sp_tank = comfort_tank_set

    # -----------------------------------------------------------------------
    # 6) Update RBC State & Return
    # -----------------------------------------------------------------------
    rbc_state['flexState']           = flexState
    rbc_state['timeInThisSubsystem'] = timeInSub
    rbc_state['preheatTarget']       = preheatTarget

    return (
        T_sp_zone,      # recommended zone setpoint
        T_sp_tank,      # recommended tank setpoint
        T_amb_w,        # weighted ambient temperature
        HEP_w,          # weighted electricity price
        F1, F2, F3,     # sub-horizon price aggregates
        Fwd_val,        # usage forecast
        rbc_state       # updated RBC state
    )
