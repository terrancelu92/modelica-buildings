within Buildings.Templates.Plants.HeatPumps.Validation;
model FourPipeASHP_with_controls_templatemodel
  "Validation of AWHP plant template"
  extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium);
  replaceable package Medium=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";
  replaceable package MediumAir=Buildings.Media.Air
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";
  parameter Real mHeaWatPri_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal;
  parameter Real mChiWatPri_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal;
  parameter Boolean have_chiWat=true
    "Set to true if the plant provides CHW"
    annotation (Evaluate=true,
    Dialog(group="Configuration"));
  inner parameter UserProject.Data.AllSystems datAll
    "Plant parameters"
    annotation (Placement(transformation(extent={{142,40},{162,60}})));

  parameter Boolean allowFlowReversal=true
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation (Dialog(tab="Assumptions"),
    Evaluate=true);
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Evaluate=true,
    Dialog(tab="Dynamics",group="Conservation equations"));

  parameter Modelica.Units.SI.Temperature THwSup_nominal=323.15
    "HW supply temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature THwRet_nominal=315.15
    "HW return temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TChwSup_nominal=280.15
    "CHW supply temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TChwRet_nominal=285.15
    "CHW return temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TAmbHea_nominal=268.15
    "OA temperature"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal = 58E3
    "Heating heat flow rate - Heating mode"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.HeatFlowRate QHeaShc_flow_nominal = 85E3
    "Heating heat flow rate - SHC mode"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.Temperature TAmbCoo_nominal=308.15
    "Ambient side fluid temperature — Entering or leaving depending on use_TAmbOutForTab"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal = -73E3
    "Cooling heat flow rate - Cooling mode"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.HeatFlowRate QCooShc_flow_nominal = -65E3
    "Cooling heat flow rate - SHC mode"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.MassFlowRate mHw_flow_nominal=
    QHea_flow_nominal / (THwSup_nominal - THwRet_nominal) /
    Buildings.Media.Water.cp_const
    "HW mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate mChw_flow_nominal=
    QCoo_flow_nominal / (TChwSup_nominal - TChwRet_nominal) /
    Buildings.Media.Water.cp_const
    "CHW mass flow rate"
    annotation (Dialog(group="Nominal condition"));

  Fluid.FixedResistances.CheckValve cheVal(
    redeclare package Medium = Medium,
    m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal,
    dpValve_nominal=500,
    dpFixed_nominal=40000)
    annotation (Placement(transformation(extent={{-68,-290},{-48,-270}})));
  Fluid.Movers.Preconfigured.SpeedControlled_y     mov1(
    redeclare package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal,
    dp_nominal=datAll.pla.pumHeaWatPri.dp_nominal[1])
    annotation (Placement(transformation(extent={{-40,-270},{-20,-290}})));
  Fluid.Movers.Preconfigured.SpeedControlled_y     mov2(
    redeclare package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal,
    dp_nominal=datAll.pla.pumChiWatPri.dp_nominal[1])
    annotation (Placement(transformation(extent={{80,-260},{60,-240}})));
  Fluid.FixedResistances.CheckValve cheVal1(
    redeclare package Medium = Medium,
    m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal,
    dpValve_nominal=500,
    dpFixed_nominal=40000)
    annotation (Placement(transformation(extent={{110,-260},{90,-240}})));

  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-120,-220},{-100,-200}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(t=0.05, h=0.02)
    annotation (Placement(transformation(extent={{138,-212},{158,-192}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr1(t=0.05, h=0.02)
    annotation (Placement(transformation(extent={{60,-350},{80,-330}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr2(t=50, h=10)
    annotation (Placement(transformation(extent={{90,-130},{110,-110}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1
    annotation (Placement(transformation(extent={{-80,-420},{-60,-400}})));
  Buildings.Controls.OBC.CDL.Routing.IntegerExtractor extIndInt(nin=3)
    annotation (Placement(transformation(extent={{-320,-330},{-300,-310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt[3](k={Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.cooling,
        Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.heating,
        Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.shc})
    annotation (Placement(transformation(extent={{-358,-330},{-338,-310}})));
  Fluid.Sensors.TemperatureTwoPort senTem(redeclare package Medium = Medium,
      m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal) annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={-40,-140})));
  Fluid.Sensors.TemperatureTwoPort senTem1(redeclare package Medium = Medium,
      m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal) annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={130,-158})));

  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr4(t=278)
    annotation (Placement(transformation(extent={{-20,-150},{0,-130}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea9
    annotation (Placement(transformation(extent={{20,-150},{40,-130}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(t=273.15 + 70)
    annotation (Placement(transformation(extent={{120,-30},{140,-10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea10
    annotation (Placement(transformation(extent={{160,-30},{180,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uPlaOpeMod annotation (
      Placement(transformation(extent={{-580,-320},{-540,-280}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1PumEvaEna annotation (
      Placement(transformation(extent={{-580,-260},{-540,-220}}),
        iconTransformation(extent={{-140,-140},{-100,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1PumConEna annotation (
      Placement(transformation(extent={{-580,-360},{-540,-320}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHeaPumEna annotation (
      Placement(transformation(extent={{-580,-140},{-540,-100}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet annotation (
      Placement(transformation(extent={{-580,-480},{-540,-440}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yHPEnaPro annotation (
      Placement(transformation(extent={{180,-120},{220,-80}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yPumEvaEnaPro annotation
    (Placement(transformation(extent={{180,-180},{220,-140}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yPumConEnaPro annotation
    (Placement(transformation(extent={{180,-240},{220,-200}}),
        iconTransformation(extent={{100,20},{140,60}})));
  BoundaryConditions.WeatherData.Bus
      weaBus "Weather data bus" annotation (Placement(transformation(extent={{-514,
            -110},{-440,-40}}), iconTransformation(extent={{-424,-132},{-350,
            -62}})));
  Buildings.Templates.Components.HeatPumps.AirToWaterSHC hpSHC(
    redeclare package MediumHeaWat = Medium,
    redeclare package MediumSou = Medium,
    final energyDynamics=energyDynamics,
    nUni=3,
    final dat=datHpSHC) "Multipipe heat pump"
    annotation (Placement(transformation(extent={{4,-270},{24,-290}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatSupSet annotation (
      Placement(transformation(extent={{-580,-520},{-540,-480}}),
        iconTransformation(extent={{-140,120},{-100,160}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uPumEvaSpe annotation (
      Placement(transformation(extent={{-580,-220},{-540,-180}}),
        iconTransformation(extent={{-140,-180},{-100,-140}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uPumConSpe annotation (
      Placement(transformation(extent={{-580,-420},{-540,-380}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul
    annotation (Placement(transformation(extent={{-68,-180},{-48,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul1
    annotation (Placement(transformation(extent={{-40,-440},{-20,-420}})));
  parameter Buildings.Templates.Components.Data.HeatPump datHpSHC(
    final cpHeaWat_default=hpSHC.cpHeaWat_default,
    final cpSou_default=hpSHC.cpSou_default,
    final typ=hpSHC.typ,
    final is_rev=hpSHC.is_rev,
    mChiWat_flow_nominal=mChw_flow_nominal,
    dpChiWat_nominal(displayUnit="bar") = 40000,
    capCoo_nominal=QCooShc_flow_nominal,
    TChiWatSup_nominal=TChwSup_nominal,
    TSouCoo_nominal=TAmbCoo_nominal,
    perSHC(
      fileNameHea=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_Heating.txt"),
      fileNameCoo=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_Cooling.txt"),
      fileNameShc=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_SHC.txt")),
    mHeaWat_flow_nominal=mHw_flow_nominal,
    dpHeaWat_nominal(displayUnit="bar") = 30000,
    capHea_nominal=QHeaShc_flow_nominal,
    THeaWatSup_nominal=THwSup_nominal,
    TSouHea_nominal=TAmbHea_nominal,
    dpSouWwHea_nominal(displayUnit="Pa"))
    "Simultaneous heating and cooling (SHC) air-to-water heat pump record"
    annotation (Placement(transformation(extent={{-180,-100},{-160,-80}})));
  Buildings.Templates.Components.Interfaces.Bus busHpSHC
    "SHC air-to-water heat pump control bus" annotation (Placement(
        transformation(extent={{-240,-364},{-200,-324}}),
                                                      iconTransformation(extent
          ={{-230,-40},{-190,0}})));
equation
  if have_chiWat then
  end if;
  connect(cheVal.port_b, mov1.port_a)
    annotation (Line(points={{-48,-280},{-40,-280}},   color={162,29,33}));
  connect(cheVal1.port_b, mov2.port_a)
    annotation (Line(points={{90,-250},{80,-250}},   color={0,127,255}));
  connect(conInt.y, extIndInt.u)
    annotation (Line(points={{-336,-320},{-322,-320}},
                                                 color={255,127,0}));

  connect(mov2.y_actual, greThr.u) annotation (Line(points={{59,-243},{42,-243},
          {42,-202},{136,-202}},
                        color={0,0,127}));
  connect(mov1.y_actual, greThr1.u) annotation (Line(points={{-19,-287},{-12,
          -287},{-12,-340},{58,-340}},                                  color={0,
          0,127}));

  connect(senTem.T, greThr4.u) annotation (Line(points={{-29,-140},{-22,-140}},
                                    color={0,0,127}));
  connect(greThr4.y, booToRea9.u)
    annotation (Line(points={{2,-140},{18,-140}},      color={255,0,255}));
  connect(lesThr.y, booToRea10.u)
    annotation (Line(points={{142,-20},{158,-20}},     color={255,0,255}));
  connect(senTem1.T, lesThr.u) annotation (Line(points={{141,-158},{148,-158},{
          148,-40},{112,-40},{112,-20},{118,-20}},
                                          color={0,0,127}));
  connect(cheVal.port_a, port_a2) annotation (Line(points={{-68,-280},{-76,-280},
          {-76,-76},{80,-76},{80,-60},{100,-60}},
        color={162,29,33}));
  connect(senTem1.port_b, port_b2) annotation (Line(points={{130,-148},{130,-46},
          {-100,-46},{-100,-60}},           color={255,170,170}));
  connect(cheVal1.port_a, port_a1) annotation (Line(points={{110,-250},{116,
          -250},{116,-80},{-120,-80},{-120,60},{-100,60}},
                                                     color={0,127,255}));
  connect(senTem.port_b, port_b1)
    annotation (Line(points={{-40,-130},{-40,60},{100,60}},
                                                        color={0,127,255}));
  connect(uPlaOpeMod, extIndInt.index) annotation (Line(points={{-560,-300},{-380,
          -300},{-380,-354},{-310,-354},{-310,-332}}, color={255,127,0}));
  connect(greThr2.y, yHPEnaPro) annotation (Line(points={{112,-120},{168,-120},
          {168,-100},{200,-100}},color={255,0,255}));
  connect(greThr1.y, yPumConEnaPro) annotation (Line(points={{82,-340},{160,
          -340},{160,-220},{200,-220}},                 color={255,0,255}));
  connect(greThr.y, yPumEvaEnaPro) annotation (Line(points={{160,-202},{168,
          -202},{168,-160},{200,-160}},              color={255,0,255}));
  connect(u1PumConEna, booToRea1.u) annotation (Line(points={{-560,-340},{-400,
          -340},{-400,-410},{-82,-410}}, color={255,0,255}));
  connect(u1PumEvaEna, booToRea.u) annotation (Line(points={{-560,-240},{-140,
          -240},{-140,-210},{-122,-210}},
                       color={255,0,255}));
  connect(booToRea1.y, mul1.u1) annotation (Line(points={{-58,-410},{-56,-410},
          {-56,-416},{-42,-416},{-42,-424}}, color={0,0,127}));
  connect(uPumConSpe, mul1.u2) annotation (Line(points={{-560,-400},{-156,-400},
          {-156,-436},{-42,-436}}, color={0,0,127}));
  connect(uPumEvaSpe, mul.u1) annotation (Line(points={{-560,-200},{-276,-200},
          {-276,-156},{-80,-156},{-80,-164},{-70,-164}}, color={0,0,127}));
  connect(mul1.y, mov1.y) annotation (Line(points={{-18,-430},{-12,-430},{-12,
          -344},{-16,-344},{-16,-300},{-30,-300},{-30,-292}}, color={0,0,127}));
  connect(booToRea.y, mul.u2) annotation (Line(points={{-98,-210},{-92,-210},{
          -92,-176},{-70,-176}}, color={0,0,127}));
  connect(mul.y, mov2.y) annotation (Line(points={{-46,-170},{64,-170},{64,-232},
          {70,-232},{70,-238}}, color={0,0,127}));
  connect(hpSHC.port_a, mov1.port_b)
    annotation (Line(points={{4,-280},{-20,-280}}, color={162,29,33}));
  connect(hpSHC.port_b, senTem1.port_a) annotation (Line(points={{24,-280},{130,
          -280},{130,-168}}, color={255,170,170}));
  connect(hpSHC.port_aSou, mov2.port_b) annotation (Line(points={{24,-270},{46,
          -270},{46,-250},{60,-250}}, color={0,127,255}));
  connect(hpSHC.port_bSou, senTem.port_a) annotation (Line(points={{4,-270},{
          -40,-270},{-40,-150}}, color={0,127,255}));
  connect(weaBus, hpSHC.busWea) annotation (Line(
      points={{-477,-75},{-477,-300},{8,-300},{8,-290}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(busHpSHC, hpSHC.bus) annotation (Line(
      points={{-220,-344},{14,-344},{14,-290}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(greThr2.u, busHpSHC.P) annotation (Line(points={{88,-120},{-220,-120},
          {-220,-344}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(uHeaPumEna, busHpSHC.y1) annotation (Line(points={{-560,-120},{-220,
          -120},{-220,-344}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(extIndInt.y, busHpSHC.mode) annotation (Line(points={{-298,-320},{
          -252,-320},{-252,-344},{-220,-344}}, color={255,127,0}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(TChiWatSupSet, busHpSHC.TChwSet) annotation (Line(points={{-560,-460},
          {-220,-460},{-220,-344}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(THotWatSupSet, busHpSHC.THwSet) annotation (Line(points={{-560,-500},
          {-220,-500},{-220,-344}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (
    __Dymola_Commands(
      file=
        "modelica://Buildings/Resources/Scripts/Dymola/Templates/Plants/HeatPumps/Validation/AirToWater.mos"
        "Simulate and plot"),
    experiment(
      StartTime=11145600,
      StopTime=11750400,
      Interval=600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(
      info="<html>
<p>
This model validates
<a href=\"modelica://Buildings.Templates.Plants.HeatPumps.AirToWater\">
Buildings.Templates.Plants.HeatPumps.AirToWater</a>
by simulating a <i>24</i>-hour period with overlapping heating and
cooling loads.
The heating loads reach their peak value first, the cooling loads reach it last.
</p>
<p>
Three equally sized heat pumps are modeled, which can all be lead/lag alternated.
A heat recovery chiller is included (<code>pla.have_hrc_select=true</code>) 
and connected to the HW and CHW return pipes (sidestream integration).
A unique aggregated load is modeled on each loop by means of a cooling or heating
component controlled to maintain a constant <i>&Delta;T</i>
and a modulating valve controlled to track a prescribed flow rate.
An importance multiplier of <i>10</i> is applied to the plant requests
and reset requests generated from the valve position.
</p>
<p>
The user can toggle the top-level parameter <code>have_chiWat</code>
to switch between a cooling and heating system (the default setting)
to a heating-only system.
Advanced equipment and control options can be modified via the parameter
dialog of the plant component.
</p>
<p>
Simulating this model shows how the plant responds to a varying load by
</p>
<ul>
<li>
staging or unstaging the AWHPs and associated primary pumps,
</li>
<li>
rotating lead/lag alternate equipment to ensure even wear,
</li>
<li>
resetting the supply temperature and remote differential pressure
in both the CHW and HW loops based on the valve position,
</li>
<li>
staging and controlling the secondary pumps to meet the
remote differential pressure setpoint.
</li>
</ul>
<h4>Details</h4>
<p>
By default, all valves within the plant are modeled considering a linear
variation of the pressure drop with the flow rate (<code>pla.linearized=true</code>),
as opposed to the quadratic relationship usually considered for
a turbulent flow regime.
By limiting the size of the system of nonlinear equations, this setting
reduces the risk of solver failure and the time to solution for testing
various plant configurations.
</p>
</html>",
      revisions="<html>
<ul>
<li>
May 31, 2024, by Antoine Gautier:<br/>
Added sidestream HRC and refactored the model after updating the HP plant template.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3808\">#3808</a>.
</li>
<li>
March 29, 2024, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(
      coordinateSystem(
        extent={{-540,-480},{180,80}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}), graphics={Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-34},{100,-88}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,84},{100,30}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid)}));
end FourPipeASHP_with_controls_templatemodel;
