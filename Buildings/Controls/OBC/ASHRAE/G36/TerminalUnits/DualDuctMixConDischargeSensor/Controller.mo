within Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor;
block Controller "Controller for dual-duct terminal unit using mixing control with discharge flow sensor"

  parameter Boolean have_winSen=true
    "True: the zone has window sensor";
  parameter Boolean have_occSen=true
    "True: the zone has occupancy sensor";
  parameter Boolean have_CO2Sen=true
    "True: the zone has CO2 sensor";
  parameter Boolean permit_occStandby=true
    "True: occupied-standby mode is permitted";
  // ---------------- Design parameters ----------------
  parameter Real AFlo(unit="m2")
    "Zone floor area"
    annotation (Dialog(group="Design conditions"));
  parameter Real desZonPop "Design zone population"
    annotation (Dialog(group="Design conditions"));
  parameter Real outAirRat_area=0.0003
    "Outdoor airflow rate per unit area, m3/s/m2"
    annotation (Dialog(group="Design conditions"));
  parameter Real outAirRat_occupant=0.0025
    "Outdoor airflow rate per occupant, m3/s/p"
    annotation (Dialog(group="Design conditions"));
  parameter Real CO2Set=894
    "CO2 concentration setpoint, ppm"
    annotation (Dialog(group="Design conditions"));
  parameter Real VZonMin_flow(unit="m3/s")
    "Design zone minimum airflow setpoint"
    annotation (Dialog(group="Design conditions"));
  parameter Real VCooZonMax_flow(unit="m3/s")
    "Design zone cooling maximum airflow rate"
    annotation (Dialog(group="Design conditions"));
  parameter Real VHeaZonMax_flow(unit="m3/s")
    "Design zone heating maximum airflow rate"
    annotation (Dialog(group="Design conditions"));
  // ---------------- Control loop parameters ----------------
  parameter Real kCooCon=1
    "Gain of controller for cooling control loop"
    annotation (Dialog(tab="Control loops", group="Cooling"));
  parameter Real TiCooCon(unit="s")=0.5
    "Time constant of integrator block for cooling control loop"
    annotation (Dialog(tab="Control loops", group="Cooling"));
  parameter Real kHeaCon=1
    "Gain of controller for heating control loop"
    annotation (Dialog(tab="Control loops", group="Heating"));
  parameter Real TiHeaCon(unit="s")=0.5
    "Time constant of integrator block for heating control loop"
    annotation (Dialog(tab="Control loops", group="Heating"));
  // ---------------- Dampers control parameters ----------------
  parameter Boolean have_pressureIndependentDamper
    "True: the VAV damper is pressure independent (with built-in flow controller)"
    annotation (Dialog(tab="Dampers"));
  parameter Real V_flow_nominal(unit="m3/s")
    "Nominal volume flow rate, used to normalize control error"
    annotation (Dialog(tab="Dampers"));
  parameter CDL.Types.SimpleController controllerTypeDam=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller"
    annotation (Dialog(tab="Dampers",
      enable=not have_pressureIndependentDamper));
  parameter Real kDam=0.5
    "Gain of controller for damper control"
    annotation (Dialog(tab="Dampers",
      enable=not have_pressureIndependentDamper));
  parameter Real TiDam(unit="s")=300
    "Time constant of integrator block for damper control"
    annotation (Dialog(tab="Dampers",
      enable=not have_pressureIndependentDamper
             and (controllerTypeDam == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
                  or controllerTypeDam == Buildings.Controls.OBC.CDL.Types.SimpleController.PID)));
  parameter Real TdDam(unit="s")=0.1
    "Time constant of derivative block for damper control"
    annotation (Dialog(tab="Dampers",
      enable=not have_pressureIndependentDamper
             and (controllerTypeDam == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
                  or controllerTypeDam == Buildings.Controls.OBC.CDL.Types.SimpleController.PID)));
  parameter Real kHeaMaxDam(final unit="1")=0.5
    "Gain of controller for heating maximum damper control"
    annotation(Dialog(tab="Damper", enable=not have_pressureIndependentDamper));
  // ---------------- System request parameters ----------------
  parameter Real thrTemDif(unit="K")=3
    "Threshold difference between zone temperature and cooling setpoint for generating 3 cooling SAT reset requests"
    annotation (Dialog(tab="System requests"));
  parameter Real twoTemDif(unit="K")=2
    "Threshold difference between zone temperature and cooling setpoint for generating 2 cooling SAT reset requests"
    annotation (Dialog(tab="System requests"));
  parameter Real durTimTem(unit="s")=120
    "Duration time of zone temperature exceeds setpoint"
    annotation (Dialog(tab="System requests", group="Duration time"));
  parameter Real durTimFlo(unit="s")=60
    "Duration time of airflow rate less than setpoint"
    annotation (Dialog(tab="System requests", group="Duration time"));
  // ---------------- Parameters for alarms ----------------
  parameter Real staPreMul
    "Importance multiplier for the zone static pressure reset control loop"
    annotation (Dialog(tab="Alarms"));
  parameter Real lowFloTim(unit="s")=300
    "Threshold time to check low flow rate"
    annotation (Dialog(tab="Alarms"));
  parameter Real fanOffTim(unit="s")=600
    "Threshold time to check fan off"
    annotation (Dialog(tab="Alarms"));
  parameter Real leaFloTim(unit="s")=600
    "Threshold time to check damper leaking airflow"
    annotation (Dialog(tab="Alarms"));
  // ---------------- Parameters for time-based suppression ----------------
  parameter Real chaRat=540
    "Gain factor to calculate suppression time based on the change of the setpoint, second per degC"
    annotation (Dialog(tab="Time-based suppresion"));
  parameter Real maxSupTim(unit="s")=1800
    "Maximum suppression time"
    annotation (Dialog(tab="Time-based suppresion"));
  // ---------------- Advanced parameters ----------------
  parameter Real dTHys(unit="K")=0.25
    "Near zero temperature difference, below which the difference will be seen as zero"
    annotation (Dialog(tab="Advanced"));
  parameter Real looHys(unit="1")=0.05
    "Loop output hysteresis below which the output will be seen as zero"
    annotation (Dialog(tab="Advanced"));
  parameter Real floHys(unit="m3/s")
    "Near zero flow rate, below which the flow rate or difference will be seen as zero"
    annotation (Dialog(tab="Advanced"));
  parameter Real damPosHys(unit="1")
    "Near zero damper position, below which the damper will be seen as closed"
    annotation (Dialog(tab="Advanced"));
  parameter Real timChe(unit="s")=30
    "Threshold time to check the zone temperature status"
    annotation (Dialog(tab="Advanced", group="Control loops"));
  parameter Real conThr(unit="1")=0.1
    "Threshold value to check if the controller output is near zero"
    annotation (Dialog(tab="Advanced", group="Control loops"));
  parameter Real zonDisEff_cool(unit="1")=1.0
    "Zone cooling air distribution effectiveness"
    annotation (Dialog(tab="Advanced", group="Distribution effectiveness"));
  parameter Real zonDisEff_heat(unit="1")=0.8
    "Zone heating air distribution effectiveness"
    annotation (Dialog(tab="Advanced", group="Distribution effectiveness"));
  parameter Real samplePeriod(unit="s")=120
    "Sample period of component, set to the same value as the trim and respond that process static pressure reset"
    annotation (Dialog(tab="Advanced", group="Time-based suppresion"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TZon(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC")
    "Measured room temperature"
    annotation (Placement(transformation(extent={{-280,280},{-240,320}}),
        iconTransformation(extent={{-140,170},{-100,210}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TZonCooSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC")
    "Setpoint temperature for room for cooling"
    annotation (Placement(transformation(extent={{-280,250},{-240,290}}),
        iconTransformation(extent={{-140,150},{-100,190}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TZonHeaSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC")
    "Setpoint temperature for room for heating"
    annotation (Placement(transformation(extent={{-280,220},{-240,260}}),
        iconTransformation(extent={{-140,130},{-100,170}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uWin if have_winSen
    "Window status, true if open, false if closed"
    annotation (Placement(transformation(extent={{-280,170},{-240,210}}),
        iconTransformation(extent={{-140,100},{-100,140}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uOcc if have_occSen
    "Occupancy status, true if it is occupied, false if it is not occupied"
    annotation (Placement(transformation(extent={{-280,140},{-240,180}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uOpeMod
    "Zone operation mode"
    annotation (Placement(transformation(extent={{-280,110},{-240,150}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput ppmCO2 if have_CO2Sen
    "Detected CO2 concentration"
    annotation (Placement(transformation(extent={{-280,80},{-240,120}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDis(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC") "Measured discharge air temperature"
    annotation (Placement(transformation(extent={{-280,50},{-240,90}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TColSup(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC")
    "Cold duct supply air temperature from central air handler"
    annotation (Placement(transformation(extent={{-280,20},{-240,60}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VDis_flow(
    final min=0,
    final unit="m3/s",
    final quantity="VolumeFlowRate")
    "Measured discharge airflow rate airflow rate"
    annotation (Placement(transformation(extent={{-280,-10},{-240,30}}),
        iconTransformation(extent={{-140,-30},{-100,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCooAHU
    "Cooling air handler proven on status"
    annotation (Placement(transformation(extent={{-280,-40},{-240,0}}),
        iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotSup(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    final displayUnit="degC")
    "Hot duct supply air temperature from central air handler"
    annotation (Placement(transformation(extent={{-280,-70},{-240,-30}}),
        iconTransformation(extent={{-140,-70},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHeaAHU
    "Heating air handler proven on status"
    annotation (Placement(transformation(extent={{-280,-100},{-240,-60}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput oveFloSet
    "Index of overriding flow setpoint, 1: set to zero; 2: set to cooling maximum; 3: set to minimum flow; 4: set to heating maximum"
    annotation (Placement(transformation(extent={{-280,-200},{-240,-160}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput oveCooDamPos
    "Index of overriding cooling damper position, 1: set to close; 2: set to open"
    annotation (Placement(transformation(extent={{-280,-230},{-240,-190}}),
        iconTransformation(extent={{-140,-140},{-100,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput oveHeaDamPos
    "Index of overriding heating damper position, 1: set to close; 2: set to open"
    annotation (Placement(transformation(extent={{-280,-260},{-240,-220}}),
        iconTransformation(extent={{-140,-160},{-100,-120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uCooDam(
    final min=0,
    final max=1,
    final unit="1") "Actual cooling damper position"
    annotation (Placement(transformation(extent={{-280,-290},{-240,-250}}),
        iconTransformation(extent={{-140,-190},{-100,-150}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uHeaDam(
    final min=0,
    final max=1,
    final unit="1")
    "Actual heating damper position"
    annotation (Placement(transformation(extent={{-280,-320},{-240,-280}}),
        iconTransformation(extent={{-140,-210},{-100,-170}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput VSet_flow(
    final min=0,
    final unit="m3/s",
    final quantity="VolumeFlowRate")
    "Airflow setpoint after considering override"
    annotation (Placement(transformation(extent={{240,160},{280,200}}),
        iconTransformation(extent={{100,170},{140,210}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yCooDamSet(
    final min=0,
    final max=1,
    final unit="1")
    "Cooling damper position setpoint after considering override"
    annotation (Placement(transformation(extent={{240,120},{280,160}}),
        iconTransformation(extent={{100,140},{140,180}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yHeaDamSet(
    final min=0,
    final max=1,
    final unit="1")
    "Heating damper position setpoint after considering override"
    annotation (Placement(transformation(extent={{240,80},{280,120}}),
        iconTransformation(extent={{100,110},{140,150}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yZonCooTemResReq
    "Zone cooling supply air temperature reset request"
    annotation (Placement(transformation(extent={{240,0},{280,40}}),
        iconTransformation(extent={{100,80},{140,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yColDucPreResReq
    "Cold duct pressure reset requests"
    annotation (Placement(transformation(extent={{240,-30},{280,10}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yZonHeaTemResReq
    "Zone heating supply air temperature reset request"
    annotation (Placement(transformation(extent={{240,-60},{280,-20}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yHotDucPreResReq
    "Hot duct pressure reset requests"
    annotation (Placement(transformation(extent={{240,-90},{280,-50}}),
        iconTransformation(extent={{100,0},{140,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yHeaFanReq
    "Heating fan request"
    annotation (Placement(transformation(extent={{240,-120},{280,-80}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yLowFloAla
    "Low airflow alarms"
    annotation (Placement(transformation(extent={{240,-200},{280,-160}}),
        iconTransformation(extent={{100,-110},{140,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yFloSenAla
    "Airflow sensor calibration alarm"
    annotation (Placement(transformation(extent={{240,-250},{280,-210}}),
        iconTransformation(extent={{100,-140},{140,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yLeaDamAla
    "Leaking damper alarm"
    annotation (Placement(transformation(extent={{240,-300},{280,-260}}),
        iconTransformation(extent={{100,-160},{140,-120}})));

  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.ActiveAirFlow
    actAirSet(
    final VCooZonMax_flow=VCooZonMax_flow,
    final VHeaZonMax_flow=VHeaZonMax_flow)
    "Active airflow setpoint"
    annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.SystemRequests
    sysReq(
    final thrTemDif=thrTemDif,
    final twoTemDif=twoTemDif,
    final durTimTem=durTimTem,
    final durTimFlo=durTimFlo,
    final dTHys=dTHys,
    final floHys=floHys,
    final looHys=looHys,
    final damPosHys=damPosHys) "Specify system requests "
    annotation (Placement(transformation(extent={{100,-160},{120,-120}})));
  Buildings.Controls.OBC.ASHRAE.G36.ThermalZones.ControlLoops conLoo(
    final kCooCon=kCooCon,
    final TiCooCon=TiCooCon,
    final kHeaCon=kHeaCon,
    final TiHeaCon=TiHeaCon,
    final timChe=timChe,
    final dTHys=dTHys,
    final conThr=conThr)
    "Heating and cooling control loop"
    annotation (Placement(transformation(extent={{-200,200},{-180,220}})));
  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Alarms ala(
    final staPreMul=staPreMul,
    final VCooZonMax_flow=VCooZonMax_flow,
    final lowFloTim=lowFloTim,
    final fanOffTim=fanOffTim,
    final leaFloTim=leaFloTim,
    final floHys=floHys,
    final damPosHys=damPosHys) "Generate alarms"
    annotation (Placement(transformation(extent={{140,-240},{160,-220}})));
  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Overrides
    setOve(
    final VZonMin_flow=VZonMin_flow,
    final VCooZonMax_flow=VCooZonMax_flow,
    final VHeaZonMax_flow=VHeaZonMax_flow) "Override setpoints"
    annotation (Placement(transformation(extent={{60,-100},{80,-80}})));
  Buildings.Controls.OBC.ASHRAE.G36.Generic.TimeSuppression timSupCoo(
    final samplePeriod=samplePeriod,
    final chaRat=chaRat,
    final maxTim=maxSupTim,
    final dTHys=dTHys)
    "Specify suppresion time due to the zone cooling setpoint change and check if it has passed the suppresion period"
    annotation (Placement(transformation(extent={{-200,280},{-180,300}})));
  Buildings.Controls.OBC.ASHRAE.G36.VentilationZones.ASHRAE62_1.Setpoints setPoi(
    final have_winSen=have_winSen,
    final have_occSen=have_occSen,
    final have_CO2Sen=have_CO2Sen,
    final have_typTerUniWitCO2=true,
    final have_parFanPowUniWitCO2=false,
    final have_SZVAVWitCO2=false,
    final permit_occStandby=permit_occStandby,
    final AFlo=AFlo,
    final desZonPop=desZonPop,
    final outAirRat_area=outAirRat_area,
    final outAirRat_occupant=outAirRat_occupant,
    final VZonMin_flow=VZonMin_flow,
    final VCooZonMax_flow=VCooZonMax_flow,
    final CO2Set=CO2Set,
    final zonDisEff_cool=zonDisEff_cool,
    final zonDisEff_heat=zonDisEff_heat,
    final dTHys=dTHys)
    "Minimum outdoor air and minimum airflow setpoint"
    annotation (Placement(transformation(extent={{-160,140},{-140,160}})));
  Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Dampers damDuaSen(
    final have_pressureIndependentDamper=have_pressureIndependentDamper,
    final controllerTypeDam=controllerTypeDam,
    final kDam=kDam,
    final TiDam=TiDam,
    final TdDam=TdDam,
    final V_flow_nominal=V_flow_nominal,
    final kHeaMaxDam=kHeaMaxDam,
    final dTHys=dTHys,
    final looHys=looHys)
    "Dampers control when the unit has single dual airflow sensor"
    annotation (Placement(transformation(extent={{0,0},{20,40}})));
  Buildings.Controls.OBC.ASHRAE.G36.Generic.TimeSuppression timSupHea(
    final samplePeriod=samplePeriod,
    final chaRat=chaRat,
    final maxTim=maxSupTim,
    final dTHys=dTHys)
    "Specify suppresion time due to the zone heating setpoint change and check if it has passed the suppresion period"
    annotation (Placement(transformation(extent={{-200,240},{-180,260}})));

equation
  connect(TZon, timSupCoo.TZon) annotation (Line(points={{-260,300},{-220,300},{
          -220,286},{-202,286}}, color={0,0,127}));
  connect(TZon, timSupHea.TZon) annotation (Line(points={{-260,300},{-220,300},{
          -220,246},{-202,246}}, color={0,0,127}));
  connect(TZonCooSet, timSupCoo.TSet) annotation (Line(points={{-260,270},{-226,
          270},{-226,294},{-202,294}}, color={0,0,127}));
  connect(TZonHeaSet, timSupHea.TSet) annotation (Line(points={{-260,240},{-214,
          240},{-214,254},{-202,254}}, color={0,0,127}));
  connect(TZonCooSet, conLoo.TZonCooSet) annotation (Line(points={{-260,270},{-226,
          270},{-226,216},{-202,216}}, color={0,0,127}));
  connect(TZon, conLoo.TZon) annotation (Line(points={{-260,300},{-220,300},{-220,
          210},{-202,210}}, color={0,0,127}));
  connect(TZonHeaSet, conLoo.TZonHeaSet) annotation (Line(points={{-260,240},{-214,
          240},{-214,204},{-202,204}}, color={0,0,127}));
  connect(uWin, setPoi.uWin) annotation (Line(points={{-260,190},{-180,190},{-180,
          159},{-162,159}}, color={255,0,255}));
  connect(uOcc, setPoi.uOcc) annotation (Line(points={{-260,160},{-184,160},{-184,
          157},{-162,157}}, color={255,0,255}));
  connect(uOpeMod, setPoi.uOpeMod) annotation (Line(points={{-260,130},{-188,130},
          {-188,154},{-162,154}}, color={255,127,0}));
  connect(ppmCO2, setPoi.ppmCO2) annotation (Line(points={{-260,100},{-184,100},
          {-184,151},{-162,151}}, color={0,0,127}));
  connect(TZon, setPoi.TZon) annotation (Line(points={{-260,300},{-220,300},{-220,
          143},{-162,143}}, color={0,0,127}));
  connect(TDis, setPoi.TDis) annotation (Line(points={{-260,70},{-180,70},{-180,
          141},{-162,141}}, color={0,0,127}));
  connect(uOpeMod, actAirSet.uOpeMod) annotation (Line(points={{-260,130},{-188,
          130},{-188,82},{-82,82}}, color={255,127,0}));
  connect(setPoi.VOccZonMin_flow, actAirSet.VOccZonMin_flow) annotation (Line(
        points={{-138,154},{-120,154},{-120,98},{-82,98}}, color={0,0,127}));
  connect(conLoo.yCoo, damDuaSen.uCoo) annotation (Line(points={{-178,216},{-20,
          216},{-20,39},{-2,39}}, color={0,0,127}));
  connect(actAirSet.VActCooMax_flow, damDuaSen.VActCooMax_flow) annotation (
      Line(points={{-58,98},{-28,98},{-28,36},{-2,36}}, color={0,0,127}));
  connect(TColSup, damDuaSen.TColSup) annotation (Line(points={{-260,40},{-48,40},
          {-48,33},{-2,33}}, color={0,0,127}));
  connect(VDis_flow, damDuaSen.VDis_flow) annotation (Line(points={{-260,10},{-48,
          10},{-48,30},{-2,30}}, color={0,0,127}));
  connect(uCooAHU, damDuaSen.uCooAHU) annotation (Line(points={{-260,-20},{-44,-20},
          {-44,27},{-2,27}}, color={255,0,255}));
  connect(actAirSet.VActMin_flow, damDuaSen.VActMin_flow) annotation (Line(
        points={{-58,90},{-32,90},{-32,22},{-2,22}}, color={0,0,127}));
  connect(TZon, damDuaSen.TZon) annotation (Line(points={{-260,300},{-220,300},{
          -220,18},{-2,18}}, color={0,0,127}));
  connect(THotSup, damDuaSen.THotSup) annotation (Line(points={{-260,-50},{-40,-50},
          {-40,13},{-2,13}}, color={0,0,127}));
  connect(actAirSet.VActHeaMax_flow, damDuaSen.VActHeaMax_flow) annotation (
      Line(points={{-58,82},{-36,82},{-36,7},{-2,7}}, color={0,0,127}));
  connect(conLoo.yHea, damDuaSen.uHea) annotation (Line(points={{-178,204},{-24,
          204},{-24,10},{-2,10}}, color={0,0,127}));
  connect(uHeaAHU, damDuaSen.uHeaAHU) annotation (Line(points={{-260,-80},{-16,-80},
          {-16,1},{-2,1}}, color={255,0,255}));
  connect(oveFloSet, setOve.oveFloSet) annotation (Line(points={{-260,-180},{20,
          -180},{20,-82},{58,-82}}, color={255,127,0}));
  connect(damDuaSen.VColDucDis_flow_Set, setOve.VActSet_flow) annotation (Line(
        points={{22,34},{40,34},{40,-85},{58,-85}}, color={0,0,127}));
  connect(oveCooDamPos, setOve.oveCooDamPos) annotation (Line(points={{-260,-210},
          {24,-210},{24,-90},{58,-90}}, color={255,127,0}));
  connect(damDuaSen.yCooDamSet, setOve.uCooDamSet) annotation (Line(points={{22,
          29},{36,29},{36,-93},{58,-93}}, color={0,0,127}));
  connect(oveHeaDamPos, setOve.oveHeaDamPos) annotation (Line(points={{-260,-240},
          {28,-240},{28,-96},{58,-96}}, color={255,127,0}));
  connect(damDuaSen.yHeaDamSet, setOve.uHeaDamSet) annotation (Line(points={{22,
          6},{32,6},{32,-99},{58,-99}}, color={0,0,127}));
  connect(timSupCoo.yAftSup, sysReq.uAftSupCoo) annotation (Line(points={{-178,290},
          {-100,290},{-100,-121},{98,-121}}, color={255,0,255}));
  connect(TZonCooSet, sysReq.TZonCooSet) annotation (Line(points={{-260,270},{-226,
          270},{-226,-124},{98,-124}}, color={0,0,127}));
  connect(TZon, sysReq.TZon) annotation (Line(points={{-260,300},{-220,300},{-220,
          -127},{98,-127}}, color={0,0,127}));
  connect(conLoo.yCoo, sysReq.uCoo) annotation (Line(points={{-178,216},{-20,216},
          {-20,-130},{98,-130}}, color={0,0,127}));
  connect(timSupHea.yAftSup, sysReq.uAftSupHea) annotation (Line(points={{-178,250},
          {-104,250},{-104,-135},{98,-135}}, color={255,0,255}));
  connect(TZonHeaSet, sysReq.TZonHeaSet) annotation (Line(points={{-260,240},{-214,
          240},{-214,-138},{98,-138}}, color={0,0,127}));
  connect(conLoo.yHea, sysReq.uHea) annotation (Line(points={{-178,204},{-24,204},
          {-24,-141},{98,-141}}, color={0,0,127}));
  connect(damDuaSen.VDis_flow_Set, sysReq.VDis_flow_Set) annotation (Line(
        points={{22,38},{44,38},{44,-146},{98,-146}}, color={0,0,127}));
  connect(VDis_flow, sysReq.VDis_flow) annotation (Line(points={{-260,10},{-48,10},
          {-48,-149},{98,-149}}, color={0,0,127}));
  connect(uCooDam, sysReq.uCooDam) annotation (Line(points={{-260,-270},{40,-270},
          {40,-154},{98,-154}}, color={0,0,127}));
  connect(uHeaDam, sysReq.uHeaDam) annotation (Line(points={{-260,-300},{44,-300},
          {44,-157},{98,-157}}, color={0,0,127}));
  connect(VDis_flow, ala.VDis_flow) annotation (Line(points={{-260,10},{-48,10},
          {-48,-221},{138,-221}}, color={0,0,127}));
  connect(setOve.VSet_flow, ala.VActSet_flow) annotation (Line(points={{82,-84},
          {90,-84},{90,-224},{138,-224}}, color={0,0,127}));
  connect(uCooAHU, ala.uCooFan) annotation (Line(points={{-260,-20},{-44,-20},{-44,
          -229},{138,-229}}, color={255,0,255}));
  connect(uCooDam, ala.uCooDam) annotation (Line(points={{-260,-270},{40,-270},{
          40,-232},{138,-232}}, color={0,0,127}));
  connect(uHeaAHU, ala.uHeaFan) annotation (Line(points={{-260,-80},{-16,-80},{-16,
          -236},{138,-236}}, color={255,0,255}));
  connect(uHeaDam, ala.uHeaDam) annotation (Line(points={{-260,-300},{44,-300},{
          44,-239},{138,-239}}, color={0,0,127}));
  connect(setOve.VSet_flow, VSet_flow) annotation (Line(points={{82,-84},{100,-84},
          {100,180},{260,180}}, color={0,0,127}));
  connect(setOve.yCooDamSet, yCooDamSet) annotation (Line(points={{82,-90},{106,
          -90},{106,140},{260,140}}, color={0,0,127}));
  connect(setOve.yHeaDamSet, yHeaDamSet) annotation (Line(points={{82,-96},{112,
          -96},{112,100},{260,100}}, color={0,0,127}));
  connect(sysReq.yZonCooTemResReq, yZonCooTemResReq) annotation (Line(points={{122,
          -132},{140,-132},{140,20},{260,20}}, color={255,127,0}));
  connect(sysReq.yColDucPreResReq, yColDucPreResReq) annotation (Line(points={{122,
          -137},{146,-137},{146,-10},{260,-10}}, color={255,127,0}));
  connect(sysReq.yZonHeaTemResReq, yZonHeaTemResReq) annotation (Line(points={{122,
          -143},{152,-143},{152,-40},{260,-40}}, color={255,127,0}));
  connect(sysReq.yHotDucPreResReq, yHotDucPreResReq) annotation (Line(points={{122,
          -148},{158,-148},{158,-70},{260,-70}}, color={255,127,0}));
  connect(sysReq.yHeaFanReq, yHeaFanReq) annotation (Line(points={{122,-158},{164,
          -158},{164,-100},{260,-100}}, color={255,127,0}));
  connect(ala.yFloSenAla, yFloSenAla)
    annotation (Line(points={{162,-230},{260,-230}}, color={255,127,0}));
  connect(ala.yLeaDamAla, yLeaDamAla) annotation (Line(points={{162,-238},{200,-238},
          {200,-280},{260,-280}}, color={255,127,0}));
  connect(ala.yLowFloAla, yLowFloAla) annotation (Line(points={{162,-222},{200,-222},
          {200,-180},{260,-180}}, color={255,127,0}));

annotation (defaultComponentName="duaDucCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-200},{100,200}}), graphics={
        Rectangle(
        extent={{-100,-200},{100,200}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-100,240},{100,200}},
          lineColor={0,0,255},
          textString="%name"),
        Text(
          extent={{-96,-4},{-56,-18}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="VDis_flow"),
        Text(
          extent={{-100,38},{-74,24}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="TDis"),
        Text(
          visible=have_CO2Sen,
          extent={{-100,68},{-54,54}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="ppmCO2"),
        Text(
          extent={{-100,200},{-72,186}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="TZon"),
        Text(
          extent={{-98,178},{-40,164}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="TZonCooSet"),
        Text(
          extent={{-98,158},{-40,144}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="TZonHeaSet"),
        Text(
          visible=have_winSen,
          extent={{-98,128},{-72,114}},
          lineColor={255,0,255},
          pattern=LinePattern.Dash,
          textString="uWin"),
        Text(
          visible=have_occSen,
          extent={{-98,108},{-72,94}},
          lineColor={255,0,255},
          pattern=LinePattern.Dash,
          textString="uOcc"),
        Text(
          extent={{-96,-22},{-56,-38}},
          lineColor={255,0,255},
          pattern=LinePattern.Dash,
          textString="uCooAHU"),
        Text(
          extent={{-96,88},{-50,72}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="uOpeMod"),
        Text(
          extent={{-96,-90},{-50,-106}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="oveFloSet"),
        Text(
          extent={{54,198},{98,182}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="VSet_flow"),
        Text(
          extent={{42,168},{98,154}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yCooDamSet"),
        Text(
          extent={{4,112},{98,90}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yZonCooTemResReq"),
        Text(
          extent={{-98,-110},{-20,-128}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="oveCooDamPos"),
        Text(
          extent={{44,-78},{96,-98}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yLowFloAla"),
        Text(
          extent={{36,-110},{100,-126}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yFloSenAla"),
        Text(
          extent={{34,-130},{96,-146}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yLeaDamAla"),
        Text(
          extent={{-96,-44},{-62,-60}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="THotSup"),
        Text(
          extent={{-96,-64},{-56,-80}},
          lineColor={255,0,255},
          pattern=LinePattern.Dash,
          textString="uHeaAHU"),
        Text(
          extent={{-98,-130},{-20,-148}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="oveHeaDamPos"),
        Text(
          extent={{-96,-162},{-54,-176}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uCooDam"),
        Text(
          extent={{-96,-182},{-54,-196}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uHeaDam"),
        Text(
          extent={{42,138},{98,124}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yHeaDamSet"),
        Text(
          extent={{16,92},{98,72}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yColDucPreResReq"),
        Text(
          extent={{16,32},{98,12}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yHotDucPreResReq"),
        Text(
          extent={{4,54},{98,32}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yZonHeaTemResReq"),
        Text(
          extent={{40,0},{98,-18}},
          lineColor={255,127,0},
          pattern=LinePattern.Dash,
          textString="yHeaFanReq"),
        Text(
          extent={{-96,16},{-56,2}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="TColSup")}),
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-240,-320},{240,320}})),
  Documentation(info="<html>
<p>
Controller for dual-duct terminal unit using mixing control with discharge flow sensor
according to Section 5.13 of ASHRAE
Guideline 36, May 2020. It outputs discharge airflow setpoint <code>VSet_flow</code>,
cold and hot duct dampers position setpoint (<code>yCooDamSet</code>, <code>yHeaDamSet</code>),
cooling supply temperature setpoint reset request <code>yZonCooTemResReq</code>,
heating supply temperature setpoint reset request <code>yZonHeaTemResReq</code>,
cold-duct static pressure setpoint reset request <code>yColDucPreResReq</code>,
hot-duct static pressure setpoint reset request <code>yHotDucPreResReq</code>,
heating fan request <code>yHeaFanReq</code>.
It also outputs the alarms about the low airflow <code>yLowFloAla</code>,
leaking dampers, and airflow sensor(s) calibration alarm.
</p>
<p>The sequence consists of six subsequences.</p>
<h4>a. Heating and cooling control loop</h4>
<p>
The subsequence is implementd according to Section 5.3.4. The measured zone
temperature <code>TZon</code>, zone setpoints temperatures <code>TZonHeaSet</code> and
<code>TZonCooSet</code> are inputs to the instance of class 
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.ThermalZones.ZoneStates\">
Buildings.Controls.OBC.ASHRAE.G36.ThermalZones.ZoneStates</a> to generate the
heating and cooling control loop signal. 
</p>
<h4>b. Active airflow setpoint calculation</h4>
<p>
This sequence sets the active maximum airflow according to
Section 5.13.4. Depending on operation modes <code>uOpeMod</code>, it sets the
airflow rate limits for cooling and heating supply. 
See <a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.ActiveAirFlow\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.ActiveAirFlow</a>.
</p>
<h4>c. Dampers control</h4>
<p>
This sequence sets the dampers position setpoints.
The implementation is according to Section 5.13.5. The sequence outputs 
discharge airflow rate setpoint <code>VSet_flow</code>, cold and hot ducts damper
position setpoints (<code>yCooDamSet</code>, <code>yHeaDamSet</code>). See
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Dampers\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Dampers</a>.
</p>
<h4>d. System reset requests generation</h4>
<p>
According to Section 5.13.8, this sequence outputs the system reset requests, i.e.
cooling and heating supply air temperature reset requests (<code>yZonCooTemResReq</code> and
<code>yZonHeaTemResReq</code>),
cold and hot duct static pressure reset requests (<code>yColDucPreResReq</code> and
<code>yHotDucPreResReq</code>), and the heating fan requests
<code>yHeaFanReq</code>. 
See <a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.SystemRequests\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.SystemRequests</a>.
</p>
<h4>e. Alarms</h4>
<p>
According to Section 5.13.6, this sequence outputs the alarms of low discharge flow,
leaking dampers and airflow sensor calibration alarm.
See <a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Alarms\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Alarms</a>.
</p>
<h4>f. Testing and commissioning overrides</h4>
<p>
According to Section 5.13.7, this sequence allows the override the aiflow and dampers position setpoints.
See <a href=\"modelica://Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Overrides\">
Buildings.Controls.OBC.ASHRAE.G36.TerminalUnits.DualDuctMixConDischargeSensor.Subsequences.Overrides</a>.
</p>
<p>
Note that in this implementation, the system request sequence for generating hot-duct
pressure reset request needs to know the airflow setpoint. However, the damper
control sequence, which is specified in the Section 5.13.5, does not specify the
flow setpoint when the zone is in heating state. It directly maps the heating loop output
to the heating damper position. To avoid the confusion caused by the wordings in the Section
5.13.5.1.c, the damper control was implemented according
to the Figure 5.13.5.
</p>
</html>", revisions="<html>
<ul>
<li>
August 1, 2020, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end Controller;